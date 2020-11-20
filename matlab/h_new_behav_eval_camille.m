function [med_rt,mean_rt,strial_rt,behav_table] = h_new_behav_eval_camille(suj)

addpath('../scripts.m/')

pos_single                = load(['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
pos_single                = pos_single(pos_single(:,3)==0,:);
add_block                 = ones(length(pos_single),1);

pos_single                = [add_block add_block pos_single(:,2) pos_single(:,1) add_block];
[~,behav_summary,~]       = PrepAtt22_funk_pos_summary(pos_single);

behav_table               = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS'; ...
    'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON';'disON';'tarON';'CLASS';'idx_group'; 'CD'});

% behav_table                 = behav_table(behav_table.DIS==0,:);

strial_rt                   = behav_table.RT;
med_rt                      = median(behav_table.RT);
mean_rt                     = mean(behav_table.RT);