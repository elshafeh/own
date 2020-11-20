clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);

suj_list            = [suj_group{1};suj_group{2}];
suj_list            = unique(suj_list);

clearvars -except suj_list ;

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    
    load(['../data/' suj '/field/' suj '.CnD.TrialInfo.mat']);
    
    cond_sub            = {'R','L','NR','NL'};
    cond_ix_cue         = {2,1,0,0};
    cond_ix_dis         = {0,0,0,0};
    cond_ix_tar         = {[2 4],[1 3],[2 4],[1 3]};
    
    sub_trl_array       = [];
    
    for xcon = 1:length(cond_sub)
        
        
        data.trialinfo    = trialinfo;
        trials            = h_chooseTrial(data,cond_ix_cue{xcon},cond_ix_dis{xcon},cond_ix_tar{xcon});
        
        clear data
        
        con_trl_array     = PrepAtt2_fun_create_rand_array(trials,80);
        
        sub_trl_array  = [sub_trl_array con_trl_array];
        
        clear con_trl_array
        
    end
    
    save(['../data/' suj '/field/' suj '.CnD.SlctTrials.mat'],'sub_trl_array');
    
    fprintf('%s has %d\n',suj,length(sub_trl_array)); clear sub_trl_array trialinfo
    
end