function spatialfilter     = h_ramaComputeFilter(avg,leadfield,vol,ext_name)

cfg                         =   [];
cfg.method                  =   'lcmv';
cfg.grid                    =   leadfield;
cfg.headmodel               =   vol;
cfg.lcmv.keepfilter         =   'yes';
cfg.lcmv.fixedori           =   'yes';
cfg.lcmv.projectnoise       =   'yes';
cfg.lcmv.keepmom            =   'yes';
cfg.lcmv.projectmom         =   'yes';
cfg.lcmv.lambda             =   '15%';
source                      =   ft_sourceanalysis(cfg, avg); clear avg ;

spatialfilter               = cat(1,source.avg.filter{:});  clear source cfg

fprintf('\n\nSaving %50s \n\n',ext_name);

save(['../data/filter/' ext_name '.mat'],'spatialfilter','-v7.3')
