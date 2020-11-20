clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}        = allsuj(2:15,1);
suj_group{2}        = allsuj(2:15,2);

% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);

list_group          = {'old','young'};

fOUT                = '../documents/4R/PrepAtt22_TrialCount_3Cue.txt';
fid                 = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','CUE_SIDE','CUE_CAT','Ntrials');

all_trials          = zeros(28,4);

i                   = 0;

for ngroup      = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
    
        i                   = i + 1;
        
        suj                 = suj_list{sb};
        
        list_ix_cue_cat     = {'inf','inf','unf'};
        list_ix_cue_side    = {'right','left','uninformative'};
        list_ix_cue_code    = {2,1,0};
        list_ix_dis_code    = {0,0,0};
        list_ix_tar_code    = {1:4,1:4,1:4};
        
        load(['../data/' suj '/field/' suj '.CnD.TrialInfo.mat']);
        
        data_fake.trialinfo = trialinfo; clear trialinfo ;
        
        for ncue = 1:length(list_ix_cue_cat)
            
            ntrls = h_chooseTrial(data_fake,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
           
            ntrls = length(ntrls);
            
            fprintf(fid,'%s\t%s\t%s\t%s\t%.2f\n',suj,list_group{ngroup},list_ix_cue_side{ncue},list_ix_cue_cat{ncue},ntrls);
            
            all_trials(i,ncue) = ntrls;
            
            clear ntrls;
            
        end
        
        clear data_fake
        
    end
    
end

fclose(fid);

clearvars -except all_trials ;