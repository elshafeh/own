clear ; clc ; dleiftrip_addpath ;
load ../data/yctot/gavg/new.1N2L3R.CnD.pe.mat ;

gavg                = ft_timelockgrandaverage([],allsuj{:,:});
cfg                 = [];
cfg.baseline        = [-0.1 0];
gavg                = ft_timelockbaseline(cfg,gavg);

cfg                 = [];
cfg.method          = 'amplitude';
gfp_amp             = ft_globalmeanfield(cfg, gavg);

plot(gfp_amp.time,gfp_amp.avg,'LineWidth',2) ;
xlim([-1 1]) ;
set(gca,'XAxisLocation','origin')
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')