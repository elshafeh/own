function [behav_table] = h_behavdis_eval(suj)

load(['~/Dropbox/project_me/data/pat/res/' suj '_final_ds_list.mat']);

behav_summary                   = [];

for nbloc = 1:size(final_ds_list,1)

    fname                       = ['~/Dropbox/project_me/data/pat/pos/' final_ds_list{nbloc,1} '.code.pos'];
    fprintf('Loading %s\n',fname);
    pos_single                  = load(fname);
    pos_single                  = PrepAtt22_funk_pos_prepare(pos_single,1,nbloc,1);

    pos_single                  = PrepAtt22_funk_pos_recode(pos_single);

    [~,behav_single,~]          = PrepAtt22_funk_pos_summary(pos_single);

    behav_summary               = [behav_summary;behav_single];

    clear behav_single pos_single

end

behav_table                     = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc';  ...
    'code'; 'CUE' ;'DIS';'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; ...
    'CT' ;'DT' ;'cueON';'disON';'tarON';'CLASS';'idx_group'; 'CD'});
