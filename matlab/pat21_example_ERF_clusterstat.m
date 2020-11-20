% You should create a cell array with rows = subjects and columns =
% conditions ; so if you have 14 subjects and 2 conditions you should end
% up with ann array called allsuj that has 14x2 dimensions

[design,neighbours]   = h_create_design_neighbours(14,'meg','t'); 

cfg                   = [];
cfg.latency           = [0 0.4] ;         % choose latency ; note that you can use the option cfg.avgovertime
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T-test
cfg.correctm          = 'cluster';        % Type of correction
cfg.clusteralpha      = 0.05;             % First Threshold to be applied on clusters
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 2;                % min number of neighboring channels
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.design            = design;
cfg.uvar              = 1;
cfg.ivar              = 2;
stat                  = ft_timelockstatistics(cfg, allsuj{:,1}, allsuj{:,2}); % cond1 - cond2

[min_p , p_val]       = h_pValSort(stat) ; % to know the probability of all of your clusters ;
stat2plot             = h_plotmyERFstat(stat,0.05); % transofrm stat into a plotable structure ;

cfg                    = [];
cfg.layout             = 'CTF275.lay'; % you need to always specify a layout !!
cfg.xlim               = stat.time(1):0.05:stat.time(end); % this will plot in 50ms time-windows
cfg.zlim               = [-2 2];
ft_topoplotER(cfg,stat2plot);


