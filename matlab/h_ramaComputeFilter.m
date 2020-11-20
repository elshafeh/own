function spatialfilter     = h_ramaComputeFilter(avg,leadfield,vol)

cfg                         = [];
cfg.method                  = 'lcmv';
cfg.sourcemodel             = leadfield;
cfg.headmodel               = vol;
cfg.lcmv.keepfilter         = 'yes';
cfg.lcmv.fixedori           = 'yes';
cfg.lcmv.projectnoise       = 'yes';
cfg.lcmv.keepmom            = 'yes';
cfg.lcmv.projectmom         = 'yes';
cfg.lcmv.lambda             = '5%' ;
source                      =  ft_sourceanalysis(cfg, avg);
spatialfilter               =  cat(1,source.avg.filter{:});
