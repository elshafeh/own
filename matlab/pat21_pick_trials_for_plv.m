clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list                    = [1:4 8:17];
    suj                         = ['yc' num2str(suj_list(sb))];
    load(['../data/trialinfo/' suj '.nDT.trialinfo.mat']);
    
    data.trialinfo = trialinfo ; clear trialinfo;
    
    for cnd = 1:3
        trial_list{sb,cnd} = h_chooseTrial(data,cnd-1,0,1:4);
        trial_len(sb,cnd)  = length(trial_list{sb,cnd});
    end
    
end

clearvars -except trial_*

lim = min(min(trial_len));

for sb = 1:14
    for cnd = 1:3
        trial_list{sb,cnd} = PrepAtt2_fun_create_rand_array(trial_list{sb,cnd},lim);
        trial_len(sb,cnd)  = length(trial_list{sb,cnd});
    end
end

clearvars -except trial_*

save('../data/yctot/RamaTriaList.mat','trial_list');