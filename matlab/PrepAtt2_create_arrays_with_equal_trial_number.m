clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group       = suj_group(1:2);

% alltrials           = zeros(28,4);
% i                   = 0;

for ngroup      = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        %         i                   = i + 1;
        
        fprintf('Handling %s\n',suj);
        
        load(['../data/trialinfo/' suj '.CnD.TrialInfo.mat']);
        
        data_elan               = [];
        data_elan.trialinfo     = trialinfo ;
        
        list_ix_cue             = {2,1,0,0};
        list_ix_tar             = {[2 4],[1 3],[2 4],[1 3]};
        list_ix_dis             = {0,0,0,0};
        
        clear trialinfo
        
        for cnd = 1:length(list_ix_cue)
            
            tmp                     = h_chooseTrial(data_elan,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
            
            if cnd < 3
                trial_array{cnd}        = PrepAtt2_fun_create_rand_array(tmp,80);
            else
                trial_array{cnd}        = PrepAtt2_fun_create_rand_array(tmp,40);
            end
            
            %             alltrials(i,cnd)        = length(trial_array{cnd});
            
            clear tmp
            
        end
        
        save(['../data/res/' suj '.CnD.AgeContrastEquiSlct.mat'],'trial_array');
        
        clearvars -except sb suj_list suj_group
        
    end
end