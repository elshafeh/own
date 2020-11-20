function spatialfilter = h_create_lcmv_common_filter_confound(cfg_in,data)

cfg                         = [];
cfg.latency                 = cfg_in.covariance_window;
data_select                 = ft_selectdata(cfg,data);

cfg                         = [];
cfg.covariance              = 'yes';
cfg.keeptrials              = 'yes';
cfg.covariancewindow        = cfg_in.covariance_window;
avg                         = ft_timelockanalysis(cfg,data_select);

cfg                         = [];
cfg.method                  = 'lcmv';
cfg.sourcemodel             = cfg_in.leadfield;
cfg.headmodel               = cfg_in.vol;
cfg.lcmv.keepfilter         = 'yes';
cfg.lcmv.fixedori           = 'yes';
cfg.lcmv.projectnoise       = 'yes';
cfg.lcmv.keepmom            = 'yes';
cfg.lcmv.projectmom         = 'yes';
cfg.lcmv.lambda             = '5%' ;
cfg.keeptrials              = 'yes';
source                      =  ft_sourceanalysis(cfg, avg);
spatialfilter               = source.avg.filter;
