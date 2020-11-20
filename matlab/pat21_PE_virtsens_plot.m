clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/virtual/DIS.NewDisExplore.1t90Hz.pe.mat


for cc = 1:3
    gavg{cc}        = ft_timelockgrandaverage([],allsuj{:,cc});
    cfg             = [];
    cfg.baseline    = [-0.1 -0.0];
    gavg{cc}        = ft_timelockbaseline(cfg,gavg{cc});
end

clearvars -except gavg ;

bgass = ft_timelockgrandaverage([],gavg{:});

for chan = 1:2
    
    subplot(2,1,chan)
    
    cfg                 = [];
    cfg.xlim            = [-2 0.6];
    cfg.ylim            = [-10.5^11 10.5^11];
    cfg.channel         = chan ;
    ft_singleplotER(cfg,gavg{:});
    legend({'N','L','R'})
    vline(0,'-k');
    hline(0,'-k');
    
end