clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

suj_group{1}        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

list_group          = {'prep_21'};

fOUT                = '../documents/4R/prep21_TrialCount.txt';
fid                 = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','CUE_SIDE','CUE_CAT','Ntrials');

all_trials          = zeros(14,3);

i                   = 0;

for ngroup      = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
    
        i                   = i + 1;
        
        suj                 = suj_list{sb};
        
        list_ix_cue_cat     = {'right','left','uninformative'};
        list_ix_cue_side    = {'right','left','uninformative'};
        list_ix_cue_code    = {2,1,0};
        list_ix_dis_code    = {0,0,0};
        list_ix_tar_code    = {1:4,1:4,1:4};
        
        dir_data                    = '../data/paper_data/';
        fprintf('Loading Virtual Data For %s\n',suj)
        load([dir_data suj '.CnD.prep21.AV.1t20Hz.m800p2000msCov.mat']);
        
        for ncue = 1:length(list_ix_cue_cat)
            
            ntrls = h_chooseTrial(virtsens,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
            ntrls = length(ntrls);
            fprintf(fid,'%s\t%s\t%s\t%s\t%.2f\n',[list_group{ngroup}(1) suj],list_group{ngroup},list_ix_cue_side{ncue},list_ix_cue_cat{ncue},ntrls);
            
            all_trials(i,ncue) = ntrls;
            
            clear ntrls;
            
        end
        
        clear data_fake
        
    end
    
end

fclose(fid);

clearvars -except all_trials ;