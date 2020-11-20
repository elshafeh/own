% Run Non-parametric cluster based permutation tests on Cue/Dis Locked

clear ; clc ; 

load ../data/yctot/gavg/DisfDis.pe.mat

for sb = 1:size(allsuj,1)
    for cnd_delay = 1:3
        allsuj_GA{sb,cnd_delay}         = allsuj{sb,1,cnd_delay};
        allsuj_GA{sb,cnd_delay}.avg     = allsuj{sb,1,cnd_delay}.avg - allsuj{sb,2,cnd_delay}.avg;
    end
end

clearvars -except allsuj_GA ; 

[design,neighbours] = h_create_design_neighbours(14,'meg','a'); clc;

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [-0.2 0.6];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesFunivariate';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.design              = design;
cfg.clustercritval      = 0.05;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
cfg.numrandomization    = 1000;
stat                    = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2}, allsuj_GA{:,3});

[min_p , p_val]         = h_pValSort(stat) ;

stat.mask = stat.prob < 0.05 ;

stat2plot.time      = stat.time ;
stat2plot.label     = stat.label ;
stat2plot.avg       = stat.stat .* stat.prob ;
stat2plot.dimord    =  'chan_time';

time_list = stat2plot.time(1):0.1:stat2plot.time(end);

for i = 1:(length(time_list))
    subplot(2,4,i)
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    cfg.xlim    = [time_list(i) time_list(i)+0.1];
    %     cfg.zlim    = [0 1];
    ft_topoplotER(cfg,stat2plot);
end