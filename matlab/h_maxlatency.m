function [max_lat] = h_maxlatency(avg_in,time_window,channel_focus)

cfg                                         = [];
cfg.latency                                 = time_window;
cfg.avgoverchan                          	= 'yes';
cfg.channel                                 = channel_focus;
avg_select                              	= ft_selectdata(cfg,avg_in);

vctr                                        = avg_select.avg;
fnd_max                                     = find(vctr == max(vctr));
max_lat                                     = avg_select.time(fnd_max);

