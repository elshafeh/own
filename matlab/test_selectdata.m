clc;

cfg             = [];
cfg.latency     = [-1 -0.0033];
data_select     = ft_selectdata(cfg,dataPostICA_clean);
smpl            = length(data_select.trial{1});

cfg             = [];
cfg.latency     = [-0.9967 0];
data_select     = ft_selectdata(cfg,dataPostICA_clean);
smpl2        	= length(data_select.trial{1});