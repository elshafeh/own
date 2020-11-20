clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/yctot/stat/final_gamma_sensor_disfdis.mat

[min_p, p_val]          = h_pValSort(stat) ;

% clustno                 = 1;
% stat2plot               = h_plotStat(stat,p_val(1,clustno)-0.00001,p_val(1,clustno)+0.00001);
stat2plot               = h_plotStat(stat,0.00001,0.1);

cfg                     = [];
cfg.layout              = 'CTF275.lay';
% cfg.xlim                = 0:0.1:0.6;
% cfg.zlim                = [-2 2];
cfg.marker              = 'off';
ft_topoplotER(cfg,stat2plot);

cfg=[];

cfg.channel = {'MLC16', 'MLC17', 'MLF56', 'MLF65', 'MLF66', 'MLF67', 'MLP56', 'MLP57', 'MLT12', ...
    'MLT13', 'MLT14', 'MLT15', 'MLT16', 'MLT22', 'MLT23', 'MLT24', 'MLT25', 'MLT26', 'MLT27', ...
    'MLT33', 'MLT34', 'MLT35', 'MLT36', 'MLT37', 'MLT42', 'MLT43', 'MLT44', 'MLT45', 'MLT53', ...
    'MLT54', 'MRC16', 'MRC17', 'MRC24', 'MRC25', 'MRC32', 'MRF66', 'MRF67', 'MRO14', 'MRO24', ...
    'MRO34', 'MRP35', 'MRP43', 'MRP44', 'MRP45', 'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT13', ...
    'MRT14', 'MRT15', 'MRT16', 'MRT23', 'MRT24', 'MRT25', 'MRT26', 'MRT27', 'MRT35', 'MRT36', ...
    'MRT37', 'MRT46'};

cfg.avgoverchan = 'yes';
cfg.latency     = [0 0.6];
cfg.avgovertime = 'yes';
avgoverfreq     = ft_selectdata(cfg,stat2plot);

cfg=[];

cfg.channel = {'MLC16', 'MLC17', 'MLF56', 'MLF65', 'MLF66', 'MLF67', 'MLP56', 'MLP57', 'MLT12', ...
    'MLT13', 'MLT14', 'MLT15', 'MLT16', 'MLT22', 'MLT23', 'MLT24', 'MLT25', 'MLT26', 'MLT27', ...
    'MLT33', 'MLT34', 'MLT35', 'MLT36', 'MLT37', 'MLT42', 'MLT43', 'MLT44', 'MLT45', 'MLT53', ...
    'MLT54', 'MRC16', 'MRC17', 'MRC24', 'MRC25', 'MRC32', 'MRF66', 'MRF67', 'MRO14', 'MRO24', ...
    'MRO34', 'MRP35', 'MRP43', 'MRP44', 'MRP45', 'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT13', ...
    'MRT14', 'MRT15', 'MRT16', 'MRT23', 'MRT24', 'MRT25', 'MRT26', 'MRT27', 'MRT35', 'MRT36', ...
    'MRT37', 'MRT46'};

cfg.avgoverchan = 'yes';
cfg.avgoverfreq = 'yes';
avgovertime     = ft_selectdata(cfg,stat2plot);
subplot(1,2,1)
plot(stat2plot.freq,squeeze(avgoverfreq.powspctrm),'LineWidth',2); title('Average Over Time');
ylim([0 0.5]);xlim([avgoverfreq.freq(1) avgoverfreq.freq(end)]);
hline(mean(avgoverfreq.powspctrm),'-k');
subplot(1,2,2)
plot(stat2plot.time,squeeze(avgovertime.powspctrm),'LineWidth',2); title('Average Over Frequency');
ylim([0 0.5]);xlim([avgovertime.time(1) avgovertime.time(end)]);
hline(mean(avgovertime.powspctrm),'-k');