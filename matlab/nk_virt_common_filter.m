function [spatialfilter]    = nk_virt_common_filter(data_in,cov_window,leadfield,vol)

cfg                         = [];
cfg.covariance              = 'yes';
cfg.covariancewindow        = cov_window;
avg                         = ft_timelockanalysis(cfg,data_in);

tmp_time1                   = ['m' num2str(abs(cov_window(1))*1000)];
tmp_time2                   = ['p' num2str(abs(cov_window(2))*1000) 'ms'];
ext_name                    = ['Covariance.' tmp_time1 tmp_time2 '.CF4V'];

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



