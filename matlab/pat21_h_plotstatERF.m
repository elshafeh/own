function stat2plot = h_plotstatERF(data1,data2,plim)

cfg             = [];
cfg.parameter   = 'avg';
cfg.operation   = 'x1-x2';
stat2plot       = ft_math(cfg,ft_timelockgrandaverage([],data1{:}),...
    ft_timelockgrandaverage([],data2{:}));