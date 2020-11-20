clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/yctot/stat/final_gamma_sensor_cnd.mat ;

[min_p, p_val]          = h_pValSort(stat) ;

clustno                 = 1;
stat2plot               = h_plotStat(stat,p_val(1,clustno)-0.00001,p_val(1,clustno)+0.00001);

cfg                     = [];
cfg.layout              = 'CTF275.lay';
cfg.xlim                = 0:0.1:0.6;
cfg.zlim                = [-2 2];
cfg.marker              = 'off';
ft_topoplotER(cfg,stat2plot);

cfg=[];
cfg.channel = {'MLO11', 'MLO12', 'MLO13', 'MLO21', 'MLO22', 'MLO23', 'MLP31', 'MLP41', ...
    'MLP42', 'MLP51', 'MLP52', 'MLP53', 'MLP54', 'MRO11', 'MRO12', 'MRO13', 'MRO14', ...
    'MRO21', 'MRO22', 'MRO23', 'MRO24', 'MRO33', 'MRO34', 'MRP31', 'MRP41', 'MRP42', ...
    'MRP51', 'MRP52', 'MRP53', 'MRP54', 'MRT16', 'MRT26', 'MRT27', 'MRT37', 'MRT47', 'MZO01', 'MZP01'};
cfg.avgoverchan = 'yes';
cfg.latency     = [0.1 0.5];
cfg.avgovertime = 'yes';
avgoverfreq     = ft_selectdata(cfg,stat2plot);

cfg=[];
cfg.channel = {'MLO11', 'MLO12', 'MLO13', 'MLO21', 'MLO22', 'MLO23', 'MLP31', 'MLP41', ...
    'MLP42', 'MLP51', 'MLP52', 'MLP53', 'MLP54', 'MRO11', 'MRO12', 'MRO13', 'MRO14', ...
    'MRO21', 'MRO22', 'MRO23', 'MRO24', 'MRO33', 'MRO34', 'MRP31', 'MRP41', 'MRP42', ...
    'MRP51', 'MRP52', 'MRP53', 'MRP54', 'MRT16', 'MRT26', 'MRT27', 'MRT37', 'MRT47', 'MZO01', 'MZP01'};
cfg.avgoverchan = 'yes';
cfg.avgoverfreq = 'yes';
avgovertime     = ft_selectdata(cfg,stat2plot);
subplot(1,2,1)
plot(stat2plot.freq,squeeze(avgoverfreq.powspctrm),'LineWidth',2); title('Average Over Time');
ylim([0 1.5]);xlim([avgoverfreq.freq(1) avgoverfreq.freq(end)]);
hline(mean(avgoverfreq.powspctrm),'-k');
subplot(1,2,2)
plot(stat2plot.time,squeeze(avgovertime.powspctrm),'LineWidth',2); title('Average Over Frequency');
ylim([0 1.5]);xlim([avgovertime.time(1) avgovertime.time(end)]);
hline(mean(avgovertime.powspctrm),'-k');