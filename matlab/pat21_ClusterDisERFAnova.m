clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/D123.1.Dis.2.fDis.pe.mat

for sb = 1:size(allsuj,1)
    
    for cnd = 1:size(allsuj,3)
        
        allsuj_GA{sb,cnd}       = allsuj{1,1,1};
        allsuj_GA{sb,cnd}.avg   = allsuj{sb,1,cnd}.avg - allsuj{sb,2,cnd}.avg;
        
        %         cfg                     = [];
        %         cfg.baseline            = [-0.1 0];
        %         allsuj_GA{sb,cnd}       = ft_timelockbaseline(cfg,allsuj_GA{sb,cnd});
        
        smooth_wind = 0.05;
        smooth_list = -0.1:smooth_wind:0.55;
        
        new_avg     = [];
        
        for t = 1:length(smooth_list)
            
            lm1     = find(round(allsuj_GA{sb,cnd}.time,4) == round(smooth_list(t)-smooth_wind,4));
            lm2     = find(round(allsuj_GA{sb,cnd}.time,4) == round(smooth_list(t)+smooth_wind,4));
            
            new_avg = [new_avg squeeze(mean(allsuj_GA{sb,cnd}.avg(:,lm1:lm2),2))]; clear lm1 lm2
            
        end
        
        allsuj_GA{sb,cnd}.time = smooth_list;
        allsuj_GA{sb,cnd}.avg  = new_avg ; clear new_avg ;
        
    end
end

[design,neighbours] = h_create_design_neighbours(14,'meg','a'); clc;

cfg                     = [];
cfg.channel             = 'MEG';
% cfg.latency             = [-0.1 0.6];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesFunivariate';
cfg.correctm            = 'cluster';

cfg.clusteralpha        = 0.01; %
cfg.clustercritval      = 0.01; %

cfg.alpha               = 0.025;
cfg.minnbchan           = 4;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
cfg.numrandomization    = 1000;

stat                    = ft_timelockstatistics(cfg, allsuj_GA{:,1},allsuj_GA{:,2},allsuj_GA{:,3});
[min_p,p_val]           = h_pValSort(stat);
stat                    = rmfield(stat,'cfg');

stat.mask               = stat.prob < 0.05;
stat2plot               = allsuj_GA{1,1};
stat2plot.time          = stat.time;
stat2plot.avg           = stat.mask .* stat.stat;

cfg         = [];
cfg.layout  = 'CTF275.lay';
cfg.xlim    = stat2plot.time(1):0.1:stat2plot.time(end);
% cfg.zlim    = [-1 1];
cfg.comment ='no';
ft_topoplotER(cfg,stat2plot);