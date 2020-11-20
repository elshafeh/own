function avg_planar_comb = h_timelockanalysis(data_in)

cfg                                 = []; 
cfg.demean                          = 'yes';
cfg.baselinewindow                  = [-0.1 0];
cfg.lpfilter                        = 'yes';
cfg.lpfreq                          = 35;
data                                = ft_preprocessing(cfg,data_in);

avg                                 = ft_timelockanalysis([], data);

cfg                                 = [];
cfg.method                          = 'template';
cfg.neighbours                      = ft_prepare_neighbours(cfg, avg); close all;

cfg.planarmethod                    = 'sincos';
avg_planar                          = ft_megplanar(cfg, avg);

avg_planar_comb                     = ft_combineplanar([],avg_planar);