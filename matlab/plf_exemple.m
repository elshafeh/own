clear ; clc ; 

file_name = 'blabla.mat';
load(file_name) % as ye know, this load a raw data structure

cfg                 = [];
cfg.output          = 'fourier';
cfg.method          = 'mtmconvol';
cfg.taper           = 'hanning';
cfg.foi             = 1:1:120; % here I go from 1 to 120Hz 
cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5; % there's really no explanation for this :) i saw it in a tutorial
cfg.toi             = -2:.01:2;
cfg.keeptrials      ='yes';
freq                = ft_freqanalysis(cfg,data);

cfg                 = [];
cfg.index           = 'all';
cfg.indexchan       = 'all';
cfg.alpha           = 0.05;
cfg.freq            = [1 120];
cfg.time            = [-2 2];
phase_lock          = mbon_PhaseLockingFactor(freq, cfg);

% example to plot

cfg                 = [];
cfg.zlim            = [0 0.5];
cfg.xlim            = [-0.2 2];
cfg.ylim            = [1 120];
cfg.parameter       = 'powspctrm';
cfg.maskparameter   = 'mask';
cfg.maskstyle       = 'opacity';
cfg.maskalpha       = 0.5;
ft_singleplotTFR(cfg,phase_lock);