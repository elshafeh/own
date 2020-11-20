clear ; clc ;

% You should create a cell array with rows = subjects
% so if you have 14 subjects called allsuj that has 14x1 dimension
% this will contrast actiivty to the "average" of a baseline period


bsl_period      = [-0.6 -0.2]; % first thing you need to change ; baseline period 
act_period      = [0.2 1.2]; % second thing you need to change ; activity period

for a = 1:length(allsuj)
    
    cfg                                     = [];
    cfg.latency                             = act_period;
    allsuj_activation{a,1}                  = ft_selectdata(cfg, allsuj{a,1});
    
    cfg                                     = [];
    cfg.latency                             = bsl_period;
    cfg.avgovertime                         = 'yes';
    tmp                                     = ft_selectdata(cfg, allsuj{a,1});
    
    allsuj_baseline{a,1}                    = allsuj_activation{a,1};
    allsuj_baseline{a,1}.powspctrm          = repmat(tmp.powspctrm,1,1,size(allsuj_activation{a,1}.powspctrm,3));
    
    clear tmp 
    
end

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [0 0.6];
cfg.frequency           = [5 15];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
cfg.minnbchan           = 2;
stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});

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