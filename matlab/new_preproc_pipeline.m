clear;

dsFileName                          = '/project/3015079.01/raw/sub032_3015079.01_20200122_01.ds';

cfg                                 = [];
cfg.dataset                         = dsFileName;
cfg.trialfun                        = 'ft_trialfun_general';
cfg.trialdef.eventtype              = 'UPPT001';
cfg.trialdef.eventvalue             = [11 12 13];
cfg.trialdef.prestim                = 1;
cfg.trialdef.poststim               = 7;
cfg                                 = ft_definetrial(cfg);

cfg.channel                         = {'MEG'};
cfg.continuous                      = 'yes';
cfg.bsfilter                        = 'yes';
cfg.bsfreq                          = [49 51; 99 101; 149 151];
cfg.precision                       = 'single';
data                                = ft_preprocessing(cfg);

cfg                                 = [];
cfg.resamplefs                      = 300;
cfg.detrend                         = 'no';
cfg.demean                          = 'no';
data_downsample                     = ft_resampledata(cfg, data); clear data;

% check for outlier bad channels & trials
cfg                                 = [];
cfg.method                          = 'summary';
cfg.megscale                        = 1;
cfg.alim                            = 1e-12;
cfg.metric                          = 'var';
InitRej                             = ft_rejectvisual(cfg,data_downsample);