function source = h_freq2sourceSep(freq,com_filter,leadfield,vol)

cfg                     = [];
cfg.method              = 'dics';
cfg.frequency           = freq.freq;
cfg.grid                = leadfield;
cfg.grid.filter         = com_filter ;
cfg.headmodel           = vol;
cfg.dics.fixedori       = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
source                  = ft_sourceanalysis(cfg, freq);
source                  = source.avg.pow;