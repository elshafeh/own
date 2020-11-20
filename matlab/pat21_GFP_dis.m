clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/Concat_DisfDis.pe.mat ;

for cdis = 1:2
    gavg{cdis}        = ft_timelockgrandaverage([],allsuj{:,cdis});
end

cfg                 = [];
cfg.parameter       = 'avg';
cfg.operation       = 'subtract';
gavg_diff           = ft_math(cfg,gavg{1},gavg{2});

cfg                 = [];
cfg.baseline        = [-0.1 -0];
gavg_diff_bsl       = ft_timelockbaseline(cfg,gavg_diff);

cfg                 = [];
cfg.method          = 'amplitude';
gfp_amp             = ft_globalmeanfield(cfg, gavg_diff);
gfp_bsl             = ft_globalmeanfield(cfg, gavg_diff_bsl);

subplot(2,1,1)
plot(gfp_amp.time,gfp_amp.avg,'k','LineWidth',6) ;  xlim([-1 1]) ; ylim([0 50]);
subplot(2,1,2)
plot(gfp_bsl.time,gfp_bsl.avg,'k','LineWidth',6) ;  xlim([-1 1]) ; ylim([0 50]);


% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')