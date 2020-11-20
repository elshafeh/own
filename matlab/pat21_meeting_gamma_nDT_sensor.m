clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/yctot/stat/nDTGamma.2NeighSensor.mat

[min_p, p_val]          = h_pValSort(stat) ;

clustno                 = 1;
stat2plot               = h_plotStat(stat,p_val(1,clustno)-0.00001,p_val(1,clustno)+0.00001);

cfg                     = [];
cfg.layout              = 'CTF275.lay';
% cfg.xlim                = 0:0.1:0.6;
% cfg.zlim                = [-2 2];
cfg.marker              = 'off';
ft_topoplotER(cfg,stat2plot);

cfg=[];

cfg.channel = {'MLC14', 'MLC21', 'MLC22', 'MLC23', 'MLC24', 'MLC31', 'MLC32', ...
    'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC61', ...
    'MLC62', 'MLC63', 'MLP11', 'MLP12', 'MLP22', 'MLP23', 'MLP33', 'MLP34',...
    'MLP35', 'MRC14', 'MRC21', 'MRC22', 'MRC23', 'MRC31', 'MRC32', 'MRC41', ...
    'MRC42', 'MRC51', 'MRC52', 'MRC53', 'MRC54', 'MRC55', 'MRC61', 'MRC62', ...
    'MRC63', 'MRP11', 'MRP12', 'MRP22', 'MRP23', 'MRP33', 'MRP34', 'MZC02', 'MZC03', 'MZC04'};

cfg.avgoverchan = 'yes';
cfg.latency     = [0.1 0.5];
cfg.avgovertime = 'yes';
avgoverfreq     = ft_selectdata(cfg,stat2plot);

cfg=[];

cfg.channel = {'MLC14', 'MLC21', 'MLC22', 'MLC23', 'MLC24', 'MLC31', 'MLC32', ...
    'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC61', ...
    'MLC62', 'MLC63', 'MLP11', 'MLP12', 'MLP22', 'MLP23', 'MLP33', 'MLP34',...
    'MLP35', 'MRC14', 'MRC21', 'MRC22', 'MRC23', 'MRC31', 'MRC32', 'MRC41', ...
    'MRC42', 'MRC51', 'MRC52', 'MRC53', 'MRC54', 'MRC55', 'MRC61', 'MRC62', ...
    'MRC63', 'MRP11', 'MRP12', 'MRP22', 'MRP23', 'MRP33', 'MRP34', 'MZC02', 'MZC03', 'MZC04'};

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