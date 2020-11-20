% You should create a cell array with rows = subjects and columns =
% conditions ; so if you have 14 subjects and 2 conditions you should end
% up with ann array called allsuj that has 14x2 dimensions

[design,neighbours]   = h_create_design_neighbours(14,'meg','t'); 

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [0.6 1.1];
cfg.frequency           = [5 15] ;
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
stat                    = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});

[min_p,p_val]           = h_pValSort(stat);
stat2plot               = h_plotStat(stat,0.05);

% average across frequencies and plot across time

cfg                 = [];
cfg.layout          = 'CTF275.lay';
cfg.xlim            = stat.time(1):0.05:stat.time(end);
cfg.zlim            = [-3 3];
ft_topoplotTFR(cfg,stat2plot)

% average across time and plot across frequencies 

i = 0 ;

for f = 5:15 % looking from 5Hz to 15Hz
    
    i = i + 1;
    fstep  = 0 ;
    subplot(3,3,i)
    cfg                 = [];
    cfg.layout          = 'CTF275.lay';
    cfg.ylim            = [f f+fstep]; % he'll average between these two values 
    cfg.zlim            = [-3 3];
    ft_topoplotTFR(cfg,stat2plot)
    
end