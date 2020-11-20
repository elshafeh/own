function [med_rt,mean_rt,perc_corr,ntrial,strial_rt] = h_new_behav_eval(suj,list_cue,list_dis,list_tar)

addpath('../scripts.m/')

pos_single                      = load(['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
pos_single                      = pos_single(pos_single(:,3)==0,:);
add_block                       = ones(length(pos_single),1);

pos_single                      = [add_block add_block pos_single(:,2) pos_single(:,1) add_block];
[~,behav_summary,~]             = PrepAtt22_funk_pos_summary(pos_single);

behav_table                     = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS'; ...
    'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON';'disON';'tarON';'CLASS';'idx_group'; 'CD'});

subset_behav                    = [];

for ncue = 1:length(list_cue)
    for ndis = 1:length(list_dis)
        for ntar = 1:length(list_tar)
            subset_behav = [subset_behav;behav_table(behav_table.CUE==list_cue(ncue) & behav_table.DIS==list_dis(ndis) & behav_table.TAR==list_tar(ntar),:)];
        end
    end
end

subset_behav                    = sortrows(subset_behav,3);
final_behav                     = subset_behav;

strial_rt                       = final_behav.RT;

med_rt                          = median(final_behav.RT);
mean_rt                         = mean(final_behav.RT);
perc_corr                       = length(final_behav.RT)/length(subset_behav.RT) * 100;
ntrial                          = length(final_behav.RT);