clear; close all;

load('../../data/stat/alpha_emergence_sens_stat.mat')

i                           = 0;

i                           = i + 1;
subplot(1,2,i)
hold on

for ng = 1:2
    
    plimit                  = 0.05;
    nw_data                 = h_plotStat(stat{ng,1},10e-20,plimit);
    
    cfg                     = [];
    cfg.avgoverchan         = 'yes';
    nw_data                 = ft_selectdata(cfg,nw_data);
    
    plot(nw_data.freq,squeeze(nanmean(nw_data.powspctrm,3)),'LineWidth',2.5);
    xlim([5 30]);
    grid;
    
end

i                           = i + 1;
subplot(1,2,i)
hold on

for ng = 1:2
    
    plimit                  = 0.05;
    nw_data                 = h_plotStat(stat{ng,1},10e-20,plimit);
    
    cfg                     = [];
    cfg.avgoverchan         = 'yes';
    nw_data                 = ft_selectdata(cfg,nw_data);
    
    plot(nw_data.time,squeeze(nanmean(nw_data.powspctrm,2)),'LineWidth',2.5);
    xlim([0 1.2])
    
end