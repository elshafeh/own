function cfg = h_prepare_cluster_source(f_threshold,source)

cfg                              =   [];
cfg.dim                          =   source.dim;
cfg.method                       =   'montecarlo';
cfg.statistic                    =   'depsamplesT';
cfg.parameter                    =   'pow';
cfg.correctm                     =   'cluster';
cfg.clusteralpha                 =   f_threshold;             % First Threshold
cfg.clusterstatistic             =   'maxsum';
cfg.numrandomization             =   1000;
cfg.alpha                        =   0.025;
cfg.tail                         =   0;
cfg.clustertail                  =   0;
cfg.design(1,:)                  =   [1:14 1:14];
cfg.design(2,:)                  =   [ones(1,14) ones(1,14)*2];
cfg.uvar                         =   1;
cfg.ivar                         =   2;