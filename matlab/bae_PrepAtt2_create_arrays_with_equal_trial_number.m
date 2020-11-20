clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);

suj_group{1}          = {'yc21'};

for ngroup      = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        fprintf('Handling %s\n',suj);
        
        load(['../data/' suj '/field/' suj '.CnD.TrialInfo.mat']);
        
        data_elan               = [];
        data_elan.trialinfo     = trialinfo ;
        
        list_ix_cue             = {2,1,0,0};
        list_ix_tar             = {[2 4],[1 3],[2 4],[1 3]};
        list_ix_dis             = {0,0,0,0};
        
        clear trialinfo
        
        for cnd = 1:length(list_ix_cue)
            
            tmp                     = h_chooseTrial(data_elan,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
            trial_array{cnd}        = PrepAtt2_fun_create_rand_array(tmp,80);
            
            clear tmp
            
        end
        
        save(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat'],'trial_array');
        
        clearvars -except sb suj_list suj_group
        
    end
end

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
%
%
% suj_list            = [suj_group{1};suj_group{2}];
% suj_list            = unique(suj_list);
%
% clearvars -except suj_list
%
% for sb = 1:length(suj_list)
%
%     suj                 = suj_list{sb};
%
%     for cond_main           = {'CnD'}
%
%         cond_sub            = {''};
%         cond_ix_cue         = {0:2};
%         cond_ix_dis         = {0,0,0,0};
%         cond_ix_tar         = {1:4};
%
%         fname_in            = ['../data/' suj '/field/' suj '.' cond_main{:} '.mat'];
%
%         fprintf('Loading %s\n',fname_in);
%
%         load(fname_in)
%
%         load(['../data/' suj '/field/' suj '.CnD.SlctTrials.mat']);
%
%         cfg         = [];
%         cfg.trials  = sub_trl_array;
%         data_elan   = ft_selectdata(cfg,data_elan); clear  sub_trl_array;
%         data_elan   = rmfield(data_elan,'cfg');
%
%         fname_in    = ['../data/' suj '/field/' suj '.' cond_main{:} '.Slct.mat'];
%
%         fprintf('Saving %s\n',fname_in);
%
%         save(fname_in,'data_elan','-v7.3')
%
%     end
%
% end