function [max_chan] = h_maxchan(avg_in,time_window,channel_focus,nb_max_chan)

cfg                                         = [];
cfg.latency                                 = time_window;
cfg.avgovertime                             = 'yes';
cfg.channel                                 = channel_focus;
avg_select                              	= ft_selectdata(cfg,avg_in);

vctr                                        = [[1:length(avg_select.avg)]' avg_select.avg];
vctr_sort                                   = sortrows(vctr,2,'descend'); % sort from high to low

max_chan                                    = avg_select.label(vctr_sort(1:nb_max_chan,1));