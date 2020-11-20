function [ext_essai,dataica,avg]     = h_ramaPreprocess_pe(data_elan,cov_window,latency_select,suj,ext_lock)

lp_list                     = 20;

cfg                         = [];
cfg.lpfilter                = 'yes';
cfg.lpfreq                  = lp_list;
dataica                     = ft_preprocessing(cfg,data_elan);

clear data_elan

cfg                         = [];
cfg.latency                 = latency_select;
dataica                     = ft_selectdata(cfg,dataica);

cfg                         = [];
cfg.covariance              = 'yes';
cfg.covariancewindow        = cov_window;
avg                         = ft_timelockanalysis(cfg,dataica);


tmp_freq                    = ['lp' num2str(lp_list(1)) 'Hz'];
tmp_time1                   = ['m' num2str(abs(cov_window(1))*1000)];
tmp_time2                   = ['p' num2str(abs(cov_window(2))*1000) 'ms'];
ext_essai                   = [suj '.' ext_lock '.Covariance.' tmp_freq '.' tmp_time1 tmp_time2 '.CF4V'];