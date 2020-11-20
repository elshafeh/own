function spatialfilter     = h_ramaComputeFilter(avg,leadfield,vol)

cfg                         =   [];
cfg.method                  =   'lcmv';
cfg.grid                    =   leadfield;
cfg.headmodel               =   vol;
cfg.lcmv.keepfilter         =   'yes';
cfg.lcmv.fixedori           =   'yes';
cfg.lcmv.projectnoise       =   'yes';
cfg.lcmv.keepmom            =   'yes';
cfg.lcmv.projectmom         =   'yes';
cfg.lcmv.lambda             =   '5%';
source                      =   ft_sourceanalysis(cfg, avg); clear avg ;

spatialfilter               = cat(1,source.avg.filter{:});  clear source cfg
