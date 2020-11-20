clear ; clc ;  dleiftrip_addpath ;

load ../data/yctot/gavg/LRN.CnD.pe.mat ;

for sb = 1:14
    for cnd = 1:size(allsuj,2)
        
        cfg                 = [];
        cfg.baseline        = [-0.2 -0.1];
        avg                 = ft_timelockbaseline(cfg,allsuj{sb,cnd});
        cfg                 = [];
        cfg.method          = 'amplitude';
        allsuj{sb,cnd}      = ft_globalmeanfield(cfg,avg);
        
        clear avg gfp ;
    end
end

[design,~] = h_create_design_neighbours(14,'eeg','a');
neighbours = [];

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesFunivariate';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;cfg.minnbchan           = 0;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.design              = design;cfg.clustercritval      = 0.05;cfg.neighbours          = neighbours;cfg.uvar                = 1;cfg.ivar                = 2;
cfg.numrandomization    = 1000;
cfg.latency             = [0 1.1];
stat                    = ft_timelockstatistics(cfg, allsuj{:,1}, allsuj{:,2}, allsuj{:,3});

[min_p,p_val]           = h_pValSort(stat);

stat.mask   = stat.prob < 0.4;
gfp2plot    = stat.mask .* stat.stat;

plot(stat.time,gfp2plot);ylim([-3 3]);xlim([stat.time(1) stat.time(end)]);