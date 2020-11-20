function com_filter = h_freq2sourceCommon(freq,leadfield,vol)

cfg                     = [];
cfg.method              = 'dics';
cfg.frequency           = freq.freq;
cfg.grid                = leadfield;
cfg.headmodel           = vol;
cfg.dics.fixedori       = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
cfg.dics.keepfilter     = 'yes';
source                  = ft_sourceanalysis(cfg, freq);
com_filter              = source.avg.filter;
