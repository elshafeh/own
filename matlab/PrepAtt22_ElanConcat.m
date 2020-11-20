clear ; clc ;

suj_list    = dir('/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/Sensor_Jumps/_old/');
addpath(genpath('../../../fieldtrip-20151124/'));

for sb = 1:length(suj_list)
    
    if length(suj_list(sb).name) > 2 && length(suj_list(sb).name) < 5
        
        suj                     = suj_list(sb).name;

        FicName     = ['../data/' suj '/res/' suj '.batch.concat'];
        fid         = fopen(FicName,'w+');
        fprintf(fid,'#!/bin/bash\n');
        fprintf(fid,'\n');
        fprintf(fid,'eegconcat<<!\n');
        
        load(['../data/' suj '/res/' suj '_final_ds_list.mat']);

        for nbloc = 1:length(final_ds_list)
            
            dirSingleIn = ['../data/' suj '/meeg/single/' final_ds_list{nbloc,2}(1:end-3) '.meeg'];
            fprintf(fid,'%s\n',dirSingleIn);
            
        end
        
        dirConcatOut    = ['../data/' suj '/meeg/' suj '.pat22.3rdOrder.jc.offset.meeg'];
        
        fprintf(fid,'\n');
        fprintf(fid,'%s\n',dirConcatOut);
        
        fprintf(fid,'\n');
        fprintf(fid,'!\n');
        fclose(fid);
        
        if ~exist(dirConcatOut)
            system(['chmod 777 ' FicName]);
            system(['bash ' FicName]);
        end
    end
end