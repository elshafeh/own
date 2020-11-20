clear ; clc ; 

fname_in = load('../data/elan/yc10.pt1.DIS.mat');

load(fname_in) ; % load your data_elan file

% pre-process
cfg                     = [];
cfg.bpfilter            = 'yes';
cfg.bpfreq              = [0.5 20];
data_pre                = ft_preprocessing(cfg,data_elan);

% choose trial & average 
cfg                             = [];
cfg.trials                      = h_chooseTrial(data_pre,1,0,1:4); % or you can put 'all'
avg                             = ft_timelockanalysis(cfg,data_f);

% baseline correction 
cfg                     = [];
cfg.baseline            = [-0.2 -0.1]; % time is represented in seconds
avg_bsl                 = ft_timelockbaseline(cfg,avg);

% plotting tools
ft_singleplotER(cfg,avg_bsl) % single or mean of multiple channels
ft_multiplotER(cfg,avg_bsl) % overview plot of single channels
ft_topoplotER(cfg,avg_bsl) % topography plot 