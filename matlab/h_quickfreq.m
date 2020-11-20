function h_quickfreq(data)

cfg                                     = [];
cfg.method                              = 'mtmfft';
cfg.output                              = 'pow';
cfg.taper                               = 'dpss';
cfg.tapsmofrq                           = 1;
freq                                    = ft_freqanalysis(cfg,data);
ft_singleplotER([],freq);

title('');