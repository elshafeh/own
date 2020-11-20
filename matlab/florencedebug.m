clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load /Volumes/heshamshung/Fieldtripping6Dec2018/data/paper_data/yc1.CnD.prep21.AV.1t20Hz.m800p2000msCov.mat

cfg             = [];
cfg.toilim      = [-2 2];
data_in         = ft_redefinetrial(cfg, virtsens);

cfg             = [];
cfg.method      = 'mtmfft';
cfg.foi         = 25; % center of frequency band-of-interest
cfg.tapsmofrq   = 15; % +/- ie frequency band definition
cfg.output      = 'powandcsd';
cfg.taper       = 'hanning'; % method to have the whole interval (deals with the edges)
freq_filter = ft_freqanalysis(cfg,data_in); clc ;