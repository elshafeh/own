function [ext_essai,dataica,avg]     = h_ramaPreprocess(data_elan,bp_list,cov_window,latency_select,suj,prt,ext_lock)

cfg                         = [];
cfg.bpfilter                = 'yes';
cfg.bpfreq                  = bp_list;
dataica                     = ft_preprocessing(cfg,data_elan);

clear data_elan

cfg                         = [];
cfg.latency                 = latency_select;
dataica                     = ft_selectdata(cfg,dataica);

cfg                         = [];
cfg.covariance              = 'yes';
cfg.covariancewindow        = cov_window;
avg                         = ft_timelockanalysis(cfg,dataica);


tmp_freq                    = [num2str(bp_list(1)) 't' num2str(bp_list(2)) 'Hz'];
tmp_time1                   = ['m' num2str(abs(cov_window(1))*1000)];
tmp_time2                   = ['p' num2str(abs(cov_window(2))*1000) 'ms'];
ext_essai                   = [suj '.pt' num2str(prt) '.' ext_lock '.Covariance.' tmp_freq '.' tmp_time1 tmp_time2 '.CF4V'];
