clear ; clc ; 

load ../data/yctot/gavg/new.1RCnD.2LCnD.3NCnDRT.4NCnDLT.pe.mat ; 
allsuj_GA = allsuj ; clear allsuj ;

for sb = 1:14

    for cnd = 1:4
        cfg                 = [];
        cfg.baseline        = [-0.1 0];
        allsuj_GA{sb,cnd}   = ft_timelockbaseline(cfg,allsuj_GA{sb,cnd});
    end
    
end

clearvars -except allsuj_GA

% Run permutation

[design,neighbours]   = h_create_design_neighbours(14,allsuj_GA{1},'meg','t'); clc;

cfg                   = [];
cfg.latency           = [0.6 1.1] ;
cfg.method            = 'montecarlo';cfg.statistic         = 'depsamplesT'; cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 2;
cfg.alpha             = 0.025;
cfg.tail              = 0;cfg.clustertail       = 0;
cfg.numrandomization  = 1000;cfg.neighbours        = neighbours;cfg.design            = design;cfg.uvar              = 1;cfg.ivar              = 2;

stat{1}                 = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
stat{2}                 = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,3});
stat{3}                 = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,4});
stat{4}                 = ft_timelockstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,3});
stat{5}                 = ft_timelockstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,4});
stat{6}                 = ft_timelockstatistics(cfg, allsuj_GA{:,3}, allsuj_GA{:,4});

for cnd_s = 1:length(stat)
    [min_p(cnd_s),p_val{cnd_s}]           = h_pValSort(stat{cnd_s});
end

for cnd_s = 1:length(stat)
    
    stat{cnd_s}.mask             = stat{cnd_s}.prob < 0.05;
    stat2plot{cnd_s}.time        = stat{cnd_s}.time;
    stat2plot{cnd_s}.label       = stat{cnd_s}.label;
    stat2plot{cnd_s}.avg         = stat{cnd_s}.stat .* stat.mask ;
    stat2plot{cnd_s}.dimord      = 'chan_time';
    
end

for cnd_s = 1:length(stat)
    
    cfg                    = [];
    cfg.layout             = 'CTF275.lay';
    %     cfg.xlim               = 0.05:0.05:0.5;
    cfg.zlim               = [-2 2];
    ft_topoplotER(cfg,stat2plot{cnd_s});
    
end

% % lst_chan = {'F3', 'F1', 'Fz', 'F2', 'F4', 'FC3', 'FC1', 'FCz', 'FC2', 'FC4', 'C3', 'C1', 'Cz', 'C2', 'C4'};
% 
% lst_chan = mean(stat2plot.avg,2);
% lst_chan = find(lst_chan~=0);
% 
% for cnd = 1:size(allsuj_GA,2)
%     gavg{cnd} = ft_timelockgrandaverage([],allsuj_GA{:,cnd});
% end
% 
% cfg             = [];
% cfg.parameter   = 'avg';
% cfg.operation   = 'subtract';
% gavg{3}         = ft_math(cfg,gavg{1},gavg{2});
% 
% for c = 1:2
%     cfg                     = [];
%     cfg.channel             = lst_chan;
%     cfg.avgoverchan         = 'yes';
%     data_slct{c}            = ft_selectdata(cfg,gavg{c});
% end
% 
% % lst_chan = {'F3', 'F1', 'Fz', 'F2', 'F4', 'FC3', 'FC1', 'FCz', 'FC2', 'FC4', 'C3', 'C1', 'Cz', 'C2', 'C4'};
% 
% close all;
% figure;
% cfg                     = [];
% cfg.layout              = 'CTF275.lay';
% cfg.xlim                = [0.3 0.5];
% cfg.comment             = 'no';
% cfg.highlight           = 'on';
% cfg.highlightsymbol     = '.';
% cfg.highlightcolor      = [1 0 0];
% cfg.highlightsize       = 25;
% cfg.highlightchannel    = lst_chan;
% cfg.marker              = 'off';
% cfg.zlim                = [-30 30];
% ft_topoplotER(cfg,gavg{1});figure;
% ft_topoplotER(cfg,gavg{2});figure;
% cfg.zlim                = [-6 6];
% ft_topoplotER(cfg,gavg{3});
% 
% figure;
% hold on;
% plot(data_slct{1}.time,data_slct{1}.avg,'b','LineWidth',6) ;  xlim([-0.1 0.6]) ; ylim([-15 15])
% plot(data_slct{2}.time,data_slct{2}.avg,'r','LineWidth',6) ;  xlim([-0.1 0.6]) ; ylim([-15 15])
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')
% 
% % cfg         = [];
% % cfg.alpha   = 0.05;
% % cfg.layout  = 'CTF275.lay';
% % ft_clusterplot(cfg,stat);
% 
% % cfg             = [];
% % cfg.parameter   = 'avg';
% % cfg.operation   = 'x1-x2';
% % stat2plot       = ft_math(cfg,ft_timelockgrandaverage([],allsuj_GA{:,1}),...
% %     ft_timelockgrandaverage([],allsuj_GA{:,2}));
% % 
% % cfg                     = [];
% % cfg.latency             = [stat.time(1) stat.time(end)];
% % stat2plot               = ft_selectdata(cfg,stat2plot);
% % stat.mask               = stat.prob < 0.05;
% % stat2plot.avg           = stat2plot.avg .* stat.mask ;
%  
% % time_list = stat2plot.time(1):0.05:stat2plot.time(end);
% % 
% % figure;
% % for i = 1:(length(time_list))
% %     subplot(4,4,i)
% %     cfg         = [];
% %     cfg.layout  = 'CTF275.lay';
% %     cfg.xlim    = [time_list(i) time_list(i)+0.05];
% %     cfg.zlim    = [-2 2];
% % %     cfg.comment             = 'no';
% %     cfg.highlight           = 'on';
% %     cfg.highlightsymbol     = '.';
% %     cfg.highlightcolor      = [1 0 0];
% %     cfg.highlightsize       = 15;
% %     cfg.highlightchannel    = lst_chan;
% %     ft_topoplotER(cfg,stat2plot);
% % end
% % 
% % for cnd = 1:size(allsuj_GA,2)
% %     gavg{cnd} = ft_timelockgrandaverage([],allsuj_GA{:,cnd});
% % end
% % 
% % cfg = [];
% % cfg.parameter = 'avg';
% % cfg.operation = 'subtract';
% % gavg{3} = ft_math(cfg,gavg{1},gavg{2});
% % 
% % lst_chan = mean(stat2plot.avg,2);
% % lst_chan = find(lst_chan>0);
% % lst_chan = stat2plot.label(lst_chan);
% % 
% % cfg                     = [];
% % cfg.layout              = 'CTF275.lay';
% % cfg.xlim                = [0.3 0.5];
% % cfg.comment             = 'no';
% % cfg.highlight           = 'on';
% % cfg.highlightsymbol     = '.';
% % cfg.highlightcolor      = [1 0 0];
% % cfg.highlightsize       = 15;
% % cfg.highlightchannel    = lst_chan;
% % cfg.zlim                = [-30 30];
% % ft_topoplotER(cfg,gavg{1});figure;
% % ft_topoplotER(cfg,gavg{2});figure;
% % cfg.zlim                = [-10 10];
% % ft_topoplotER(cfg,gavg{3});
% % 
% % cfg = [];
% % cfg.xlim                = [-0.1 0.6];
% % cfg.ylim                = [-25 25];
% % cfg.channel = lst_chan ;
% % ft_singleplotER(cfg,gavg{[1:2]});
% % 
% % for c = 1:2
% %     cfg                     = [];
% %     cfg.channel             = lst_chan;
% %     cfg.avgoverchan         = 'yes';
% %     data_slct{c}    = ft_selectdata(cfg,gavg{c});
% % end
% % 
% % figure;
% % hold on;
% % plot(data_slct{1}.time,data_slct{1}.avg,'b','LineWidth',5) ;  xlim([-0.1 0.6]) ; ylim([-25 25])
% % plot(data_slct{2}.time,data_slct{2}.avg,'r','LineWidth',5) ;  xlim([-0.1 0.6]) ; ylim([-25 25])
% % vline(0,'--k');
% % set(gca,'XAxisLocation','origin')
% % set(gca,'fontsize',18)
% % set(gca,'FontWeight','bold')
% % legend({'INF','UNF'});
% % 
% % % % figure;
% % % % cfg         = [];
% % % % cfg.layout  = 'CTF275.lay';
% % % % cfg.xlim    = [-0.3 0.7];
% % % % ft_multiplotER(cfg,gavg{:});
% % % % legend({'i-dis','u-dis'})
% % % 
% % % % 
% % % % for cnd_s = 1:length(stat)
% % % %     figure;
% % % %     cfg         = [];
% % % %     cfg.layout  = 'CTF275.lay';
% % % %     ft_multiplotER(cfg,stat2plot{cnd_s});
% % % % end
% % % % 
% % % % grandavg = ft_timelockgrandaverage([],gavg{:});
% % % % 
% % % % figure;
% % % % cfg         = [];
% % % % cfg.layout  = 'CTF275.lay';
% % % % cfg.xlim    = -0.1:0.1:0.7;
% % % % ft_topoplotER(cfg,grandavg);
% % % % legend({'dis1','dis2','dis3'})
% % % 
% % % vn_group = {'MLC13', 'MLC14', 'MLC15', 'MLC16', 'MLC17', 'MLC21', 'MLC22', 'MLC23', 'MLC24', 'MLC25', ...
% % %     'MLC31', 'MLC32', 'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC61', 'MLC62', 'MLC63', ...
% % %     'MLF46', 'MLF55', 'MLF56', 'MLF64', 'MLF65', 'MLF66', 'MLF67', 'MLP11', 'MLP12', 'MLP21', 'MLP22', 'MLP23', 'MLP31', ...
% % %     'MLP32', 'MLP33', 'MLP34', 'MLP35', 'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP55', 'MLP56', 'MLP57', 'MLT11', 'MLT12', 'MLT13', ...
% % %     'MLT14', 'MLT15', 'MLT16', 'MLT24', 'MLT25', 'MLT26', 'MRC51', 'MRC61', 'MRC63', 'MRP21', 'MZC02', 'MZC03', 'MZC04'}
% % % 
% % % cfg         = [];
% % % cfg.channel  = vn_group;
% % % cfg.xlim    = [-0.2 0.7];
% % % ft_singleplotER(cfg,gavg{:});
% % % legend({'i-dis','u-dis'})