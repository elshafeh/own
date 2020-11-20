function com_filter = nbk_common_filter(data_in,leadfield,vol,time_window,freq_interest,freq_tap)

cfg                             = [];
cfg.toilim                      = time_window;
data_in                         = ft_redefinetrial(cfg, data_in);

cfg                             = [];
cfg.method                      = 'mtmfft';
cfg.foi                         = freq_interest;
cfg.tapsmofrq                   = freq_tap;
cfg.output                      = 'powandcsd';
cfg.taper                       = 'dpss';
freq                            = ft_freqanalysis(cfg,data_in); clc ;

cfg                             = [];
cfg.method                      = 'dics';
cfg.frequency                   = freq.freq;
cfg.sourcemodel                 = leadfield;
cfg.headmodel                   = vol;
cfg.dics.keepfilter             = 'yes';
cfg.dics.fixedori               = 'yes';
cfg.dics.projectnoise           = 'yes';
cfg.dics.lambda                 = '5%';
source                          = ft_sourceanalysis(cfg, freq);

com_filter                      = source.avg.filter;