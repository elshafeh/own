clear;

load P:/3015079.01/data/sub001/preproc/sub001.firstcuelock.dwnsample100Hz.mat

cfg                 = [] ;
cfg.output          = 'pow';
cfg.method          = 'mtmconvol';
cfg.keeptrials      = 'yes';
cfg.pad             = 'maxperlen';
cfg.foi             = 0.5:0.5:30;
cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.4;
cfg.toi             = -1:0.05:4;
cfg.taper           = 'hanning';
cfg.tapsmofrq    	= 0.1 *cfg.foi;
cfg.trials          = 1:5;
freq                = ft_freqanalysis(cfg,data);
ft_singleplotTFR([],freq);title('');