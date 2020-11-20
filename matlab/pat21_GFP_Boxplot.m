clear ; clc ; dleiftrip_addpath ;
load ../data/yctot/gavg/new.1N2L3R.CnD.pe.mat ;

for sb = 1:size(allsuj,1)
    for c = 1:size(allsuj,2)
        
        cfg                 = [];
        cfg.baseline        = [-0.2 -0.1];
        avg                 = ft_timelockbaseline(cfg,allsuj{sb,c});
        
        cfg                 = [];
        cfg.method          = 'amplitude';
        avg                 = ft_globalmeanfield(cfg,avg);
        
        cfg                 = [];
        cfg.latency         = [0.6 1.1];
        cfg.avgovertime     = 'yes';
        avg                 = ft_selectdata(cfg,avg);
        
        toboxplot(sb,c)     = avg.avg ; clear avg ;
        
    end
end

boxplot(toboxplot)