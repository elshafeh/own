function regr       = h_remove_hc_confound(headpos,data)

ntrials             = length(headpos.trial);

for t = 1:ntrials
    coil1(:,t)      = [mean(headpos.trial{1,t}(1,:)); mean(headpos.trial{1,t}(2,:)); mean(headpos.trial{1,t}(3,:))];
    coil2(:,t)      = [mean(headpos.trial{1,t}(4,:)); mean(headpos.trial{1,t}(5,:)); mean(headpos.trial{1,t}(6,:))];
    coil3(:,t)      = [mean(headpos.trial{1,t}(7,:)); mean(headpos.trial{1,t}(8,:)); mean(headpos.trial{1,t}(9,:))];
end

cc                  = circumcenter(coil1, coil2, coil3);
cc_dem              = [cc - repmat(mean(cc,2),1,size(cc,2))]';
confound            = [cc_dem ones(size(cc_dem,1),1)];

cfg                 = []; 
cfg.confound        = confound;
cfg.reject          = [1:6]; % keeping the constant (nr 7)
regr                = ft_regressconfound(cfg, data);