suj = 'yc2';

for list_ix_cue                 = 1:3
    
    list_ix_tar                 = 1:4;
    list_ix_dis                 = 0;
    [med_rt(list_ix_cue),~,~,~,~]    = h_behav_eval(suj,list_ix_cue-1,list_ix_dis,list_ix_tar)
    
end