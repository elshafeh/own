function cfg = h_create_cfg_for_cluster(ttest,nsubj,design,neighbours,nrand,correctm,min_nb_chan)

cfg     = [];

if strcmp(ttest,'paired')
    
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'ft_statfun_depsamplesT';
    cfg.correctm            = correctm;
    cfg.alpha               = 0.025;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = nrand;
    cfg.design              = design;
    cfg.neighbours          = neighbours;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    cfg.minnbchan           = min_nb_chan;

elseif strcmp(ttest,'unpaired')
    
    cfg                     = [];
    cfg.statistic           = 'indepsamplesT';
    cfg.method              = 'montecarlo';     
    cfg.correctm            = correctm;        
    cfg.clusteralpha        = 0.05;
    cfg.clusterstatistic    = 'maxsum';
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.alpha               = 0.025;
    cfg.numrandomization    = nrand;
    cfg.neighbours          = neighbours;
    cfg.design              = [ones(1,nsubj) ones(1,nsubj)*2];
    cfg.ivar                = 1;
    cfg.minnbchan           = min_nb_chan;

end