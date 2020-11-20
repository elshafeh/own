clear ; clc ; dleiftrip_addpath ;
load ../data/yctot/gavg/new.1N2L3R.CnD.pe.mat ;

for sb = 1:size(allsuj,1)
    avg                 = ft_timelockgrandaverage([],allsuj{sb,:});    
    cfg                 = [];
    cfg.baseline        = [-0.2 -0.1];
    avg                 = ft_timelockbaseline(cfg,avg);
    cfg                 = [];
    cfg.method          = 'amplitude';
    avg                 = ft_globalmeanfield(cfg,avg);
    tmplate_time        = avg.time;
    toboxplot(sb,:)     = avg.avg ; clear avg ;
end

plot(tmplate_time,toboxplot) ; xlim([-0.1 1.4]);