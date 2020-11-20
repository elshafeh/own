clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

patient_list;
suj_group{1}                = fp_list_all;
suj_group{2}                = cn_list_all;

list_group                  = {'patient','control'};

fOUT                        = '../documents/4R/patientBehav4Jasp_medRT.txt';
fid                         = fopen(fOUT,'W+');

fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','medRtVD0','medRtVD1','medRtVD2','medRtND0','medRtND1','medRtND2');

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        fprintf('Handling %s\n',suj);
        
        list_ix_cue         = {[1 2],0};
        list_ix_dis         = {0,1,2};
        list_ix_target      = {1:4,1:4};
        
        fprintf(fid,'%s\t%s',suj,list_group{ngroup});
        
        for ncue = 1:length(list_ix_cue)
            for ndis = 1:length(list_ix_dis)
                
                fprintf(fid,'\t');
                
                [med_rt,~,~,~,~,~,~,~] =  h_behav_eval(suj,list_ix_cue{ncue},list_ix_dis{ndis},list_ix_target{ncue});
                
                fprintf(fid,'%.2f',med_rt);
                
            end
        end
        
        fprintf(fid,'\n');
        
    end
end
        
fclose(fid);    