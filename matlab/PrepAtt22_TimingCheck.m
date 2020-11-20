clear ; clc ; close all;

[~,suj_list,~]    = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');

suj_list        = suj_list(2:end-1);

behav_summary   = [];

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    ngrp                = 1;
    
    if strcmp(suj(1:2),'yc')
        
        load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
        
        for nbloc = 1:size(final_ds_list,1)
            
            fprintf('Handling %s\n',[suj ' b' num2str(nbloc)])
            
            pos_single                = load(['../data/' suj '/pos/' final_ds_list{nbloc,1} '.code.pos']);
            pos_single                = PrepAtt22_funk_pos_prepare(pos_single,sb,nbloc,ngrp);
            pos_single                = PrepAtt22_funk_pos_recode(pos_single);
            [~,behav_single,~]        = PrepAtt22_funk_pos_summary(pos_single);
            
            behav_summary             = [behav_summary;behav_single];
            
            clear behav_single pos_single
            
        end
        
    end
    
end

clearvars -except behav_summary ; clc ; close all ;

behav_table                   = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS' ...
    ;'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON' ; ...
    'disON';'tarON';'CLASS';'idx_group';'CD'});


% dist2plot{1}   = behav_table.CT;
% disOne2target  = behav_table(behav_table.DIS==1,:);
% dis2Twotarget  = behav_table(behav_table.DIS==2,:);
% dist2plot{2}   = disOne2target.CD;
% dist2plot{3}   = dis2Twotarget.CD;
% 
% clear disOne2target dis2Twotarget

hist_binwidth = 1;

% figure;
% for ndist = 1:3
%     subplot(3,1,ndist)
%     histogram(dist2plot{ndist},'BinWidth',hist_binwidth);
%     xlim([0 1300]);
%     vline(min(dist2plot{ndist}),'--k');
%     vline(max(dist2plot{ndist}),'--k');
%     title(['min = ' num2str(min(dist2plot{ndist})) ' max = ' num2str(max(dist2plot{ndist}))])
%     
% end
% behav_table = behav_table(behav_table.DIS~=0,:);
% trial_length = behav_table.CD+300+200;
% trial_check  = 1200-behav_table.CD-300-200;
% trial_length = behav_table.CD + behav_table.DT;
% histogram(trial_length,'BinWidth',hist_binwidth)
% scatter(trial_length,behav_table.CT)