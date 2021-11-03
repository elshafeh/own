function max_chan = func_nback_findmax(avg,peak_chan,max_chan_window,lmt)

cfg                             = [];
cfg.latency                     = max_chan_window;
cfg.channel                     = peak_chan;
cfg.avgovertime                 = 'yes';
data_avg                        = ft_selectdata(cfg,avg);

vctr                            = [[1:length(data_avg.avg)]' data_avg.avg];
vctr_sort                       = sortrows(vctr,2,'descend'); % sort from high to low

max_chan                        = data_avg.label(vctr_sort(1:lmt,1));