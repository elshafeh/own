cfg                     = [];
cfg.latency             = [0 .5];
cfg.method              = 'montecarlo';
cfg.statistic           = 'indepsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;        
cfg.clusterstatistic    = 'maxsum';    
cfg.minnbchan           = 3;                 
cfg.neighbours          = neighbours;
cfg.tail                = 0;                   
cfg.clustertail         = 0;
cfg.numrandomization    = 100;
cfg.ivar  = 1;

cfg.design = [ones(1,size(g1.individual,1))
ones(1,size(g1.individual,1))*2];


[stat] = ft_timelockstatistics(cfg, g1, g2);