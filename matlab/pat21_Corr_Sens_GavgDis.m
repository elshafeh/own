clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/Concat_DisfDis.pe.mat ;
load ../data/yctot/rt/rt_dis_per_delay.mat ;

for sb = 1:14
    
    suj_list            = [1:4 8:17];
    suj                 = ['yc' num2str(suj_list(sb))];
    
    cfg                 = [];
    cfg.parameter       = 'avg';
    cfg.operation       = 'subtract';
    allsuj_GA{sb,1}     = ft_math(cfg,allsuj{sb,1},allsuj{sb,2});
    
    twin                = 0.05;
    tlist               = 0:twin:0.2;
    
    nw_avg = [];
    
    for t = 1:length(tlist);
        
        lmt1        = find(round(allsuj_GA{sb,1}.time,2)==round(tlist(t),2));
        lmt2        = find(round(allsuj_GA{sb,1}.time,2)==round(tlist(t)+twin,2));
        nw_avg(:,t) = mean(allsuj_GA{sb,1}.avg(:,lmt1:lmt2),2);
        
    end
    
    allsuj_GA{sb,1}.avg     = nw_avg;
    allsuj_GA{sb,1}.time    = tlist;
    
    allsuj_rt{sb,1}         = median([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    allsuj_rt{sb,2}         = mean([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    
    clearvars -except allsuj* sb rt_dis tlist
    
end

[design,neighbours]     = h_create_design_neighbours(14,'meg','t');

cfg                     = [];
cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_correlationT'; 
cfg.clusterstatistics   = 'maxsum';cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;    
cfg.minnbchan           = 2;cfg.tail                = 0;
cfg.clustertail         = 0;cfg.alpha               = 0.025;cfg.numrandomization    = 1000;cfg.neighbours          = neighbours;
cfg.ivar                = 1;

lst_tst = {'Pearson','Spearman'};

for x = 1:2
    for y = 1:2
        cfg.design (1,1:14)     = [allsuj_rt{:,y}];
        cfg.type                = lst_tst{x};
        stat{x,y}               = ft_timelockstatistics(cfg, allsuj_GA{:});
        [min_p(x,y),p_val{x,y}] = h_pValSort(stat{x,y});
    end
end

for x = 1:2
    for y = 1:2
        stat2plot{x,y}               = h_plotmyERFstat(stat{x,y},min_p(x,y)+0.0001);
    end
end

for x = 1:2
    for y = 1:2
        figure;
        cfg             = [];
        cfg.xlim        = tlist;
        cfg.zlim        = [-4 4];
        cfg.layout      = 'CTF275.lay';
        ft_topoplotER(cfg,stat2plot{x,y})
    end
end

for x = 1:2
    for y = 1:2
        stat{x,y} = rmfield(stat{x,y},'cfg');
    end
end