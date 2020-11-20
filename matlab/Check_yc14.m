clear ; clc ;

suj         = 'yc14';

FicName     = ['../data/' suj '/res/' suj '.batch.concat'];
fid         = fopen(FicName,'w+');
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'\n');
fprintf(fid,'eegconcat<<!\n');

load(['../data/' suj '/res/' suj '_final_ds_list.mat']);

for nbloc = 2:length(final_ds_list)
    
    dirSingleIn = ['../data/' suj '/meeg/single/' final_ds_list{nbloc,2}(1:end-3) '.meeg'];
    
    system(['eegpos ' dirSingleIn '.eeg ' dirSingleIn '.pos'])
    
    parIn       = '../par/eegavg_ICA_check_yc14.par';
    
    system(['eegavg ' dirSingleIn '.eeg ' dirSingleIn '.pos ' parIn ' ' dirSingleIn '.temp.pos +norejection']);
    
    FicName = [suj '.batch'];
    
    fid = fopen(FicName,'w+');
    
    epIN = {'tempo.101','tempo.103','tempo.202','tempo.204','tempo.1001','tempo.003','tempo.002','tempo.004'};
    
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,'\n');
    
    fprintf(fid,'epavg<< !\n');
    
    fprintf(fid,'%s\n',['../check/yc14/' suj '.CnD.' num2str(nbloc) '.Check']);
    fprintf(fid,'\n');
    
    for s = 1:length(epIN)
        fprintf(fid,'%s\n',epIN{s});
    end
    
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    fprintf(fid,'!\n');
    
    fclose(fid);
    
    system(['chmod 777 ' FicName]);
    system(['bash ' FicName]);
    
    system('rm yc14.batch');
    system('rm tempo*');
    
end