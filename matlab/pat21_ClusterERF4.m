% Run Non-parametric cluster based permutation tests on Cue/Dis Locked

% Load data

clear ; clc ; 

load ../data/yctot/gavg/new.1pull2push.bp.pe.mat

for sb = 1:size(allsuj,1)
    for cnd = 1:size(allsuj,2)
        
        cfg                 = [];
        cfg.baseline        = [-0.2 -0.1];
        allsuj_GA{sb,cnd}   = ft_timelockbaseline(cfg,allsuj{sb,cnd});
        
    end
end

% allsuj_GA = allsuj ;

clearvars -except allsuj_GA

% Run permutation

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cfg                   = [];
cfg.channel           = 'MEG';
cfg.latency           = [-0.2 0.6] ;
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 2;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.design            = design;
cfg.uvar              = 1;
cfg.ivar              = 2;

stat{1}               = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
% stat{2}               = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,3});
% stat{3}               = ft_timelockstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,3});

clearvars -except stat allsuj_GA ;

for cnd_s = 1:length(stat)
    [min_p(cnd_s) , p_val{cnd_s}]         = h_pValSort(stat{cnd_s}) ;
end

for cnd_s = 1:length(stat)
    stat{cnd_s}.mask        = stat{cnd_s}.prob < 0.2;
    stat2plot{cnd_s}        = allsuj_GA{1,1};
    stat2plot{cnd_s}.time   = stat{cnd_s}.time;
    stat2plot{cnd_s}.avg    = stat{cnd_s}.mask .* stat{cnd_s}.stat;
end

for cnd_s = 1:length(stat)
    figure;
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    cfg.xlim    = -0.2:0.1:0.6;
    cfg.zlim    = [-1 1];
    ft_topoplotER(cfg,stat2plot{cnd_s});
end

figure;
cfg         = [];
cfg.layout  = 'CTF275.lay';
cfg.xlim    = [0 0.1];
% cfg.zlim    = [-1 1];
ft_topoplotER(cfg,stat2plot{1});