function [capture_median,capture_mean,tdown_median,tdown_mean,arousal_median,arousal_mean] = create_rt_corr_postrej(suj)

list_ix_cue                     = 0:2;
list_ix_tar                     = 1:4;
list_ix_dis                     = 1;

[dis1_median,dis1_mean,~,~,~]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

list_ix_dis                     = 2;
[dis2_median,dis2_mean,~,~,~]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

list_ix_dis                     = 0;
[dis0_median,dis0_mean,~,~,~]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

list_ix_cue                     = [1 2];
list_ix_tar                     = 1:4;
list_ix_dis                     = 0;
[inf_median,inf_mean,~,~,~]     = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

list_ix_cue                     = 0;
[unf_median,unf_mean,~,~,~]     = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

capture_median                  = dis2_median - dis1_median;
capture_mean                    = dis2_mean - dis1_mean;

tdown_median                    = unf_median - inf_median;
tdown_mean                      = unf_mean - inf_mean ;

arousal_median                  = dis0_median - dis1_median;
arousal_mean                    = dis0_mean - dis1_mean ;