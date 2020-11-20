function [capture_pre,capture_post,tdown_pre,tdown_post,arousal_pre,arousal_post] = create_rt_corr(suj)

list_ix_cue                     = 0:2;
list_ix_tar                     = 1:4;
list_ix_dis                     = 1;

[dis1_pre,~,~,~,~]              = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
[dis1_post,~,~,~,~]             = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

list_ix_dis                     = 2;
[dis2_pre,~,~,~,~]              = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
[dis2_post,~,~,~,~]             = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);


list_ix_dis                     = 0;
[dis0_pre,~,~,~,~]              = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
[dis0_post,~,~,~,~]             = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

list_ix_cue                     = [1 2];
list_ix_tar                     = 1:4;
list_ix_dis                     = 0;
[inf_pre,~,~,~,~]               = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
[inf_post,~,~,~,~]              = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

list_ix_cue                     = 0;
[unf_pre,~,~,~,~]               = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
[unf_post,~,~,~,~]              = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

capture_pre                     = dis2_pre - dis1_pre;
capture_post                    = dis2_post - dis1_post;

tdown_pre                       = unf_pre - inf_pre;
tdown_post                      = unf_post - inf_post ;

arousal_pre                     = dis0_pre - dis1_pre;
arousal_post                    = dis0_post - dis1_post ;