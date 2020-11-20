for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];

    fname = ['../data/' suj '/tfr/' suj '.CnD.KTPlanar.wav.5t18Hz.m3p3.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq_avg{sb}                = ft_freqbaseline(cfg,freq);
    
    cfg                         = [];
    cfg.latency                 = [0.6 1];
    cfg.frequency               = [8 10];
    cfg.avgovertime             = 'yes';
    cfg.avgoverfreq             = 'yes';
    freq_avg{sb}                = ft_selectdata(cfg,freq_avg{sb});
    
end

rt_sub = [415,457,525,636,453,760,411,392,357,683,488,553,596,512] ;

cfg                     = [];
cfg.layout              = 'CTF275.lay';
cfg.neighbours          = neighbours;
cfg.channel             = 'MEG';
cfg.avgovertime         = 'yes';
cfg.parameter           = 'powspctrm';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT_FisherZ'; % fisher
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistics   = 'maxsum';
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.ivar                = 1;
cfg.type                = 'Spearman';
cfg.computestat         = 'yes';
design(1,1:nsuj)        = rt_sub;
stat                    = ft_freqstatistics(cfg, freq_avg{:});