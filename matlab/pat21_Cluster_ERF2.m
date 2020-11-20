% Run Non-parametric cluster based permutation tests on Cue/Dis Locked

clear ; clc ; dleiftrip_addpath ; close all;

load ../data/yctot/gavg/VN_DisfDis.pe.mat ;
% load ../data/yctot/gavg/D123.1.Dis.2.fDis.pe.mat

for sb = 1:size(allsuj,1)
    
    for cnd = 1:size(allsuj,3)
        
        allsuj_GA{sb,cnd}       = allsuj{1,1,1};
        allsuj_GA{sb,cnd}.avg   = allsuj{sb,1,cnd}.avg - allsuj{sb,2,cnd}.avg;
        
        %         cfg                     = [];
        %         cfg.baseline            = [-0.1 0];
        %         allsuj_GA{sb,cnd}       = ft_timelockbaseline(cfg,allsuj_GA{sb,cnd});
        
    end
end

clearvars -except allsuj_GA

% Run permutation

[design,neighbours]   = h_create_design_neighbours(14,'meg','t'); clc;
cfg                   = [];
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 4;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.design            = design;
cfg.uvar              = 1;
cfg.ivar              = 2;
cfg.latency           = [-0.1 0.6] ;
stat{1}               = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
% stat{2}               = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
% stat{3}               = ft_timelockstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,3});

clearvars -except stat allsuj_GA ;

for cnd_s = 1:length(stat)
    [min_p(cnd_s) , p_val{cnd_s}]         = h_pValSort(stat{cnd_s}) ;
end

for cnd_s = 1:length(stat)
    stat{cnd_s}.mask        = stat{cnd_s}.prob < 0.1;
    stat2plot{cnd_s}        = allsuj_GA{1,1};
    stat2plot{cnd_s}.time   = stat{cnd_s}.time;
    stat2plot{cnd_s}.avg    = stat{cnd_s}.mask .* stat{cnd_s}.stat;
end

% i  = 0 ;
% for cnd_s = 1:length(stat)
%     for t = -0.1:0.1:0.5
%         i = i + 1;
%         subplot(length(stat),length(-0.1:0.1:0.5),i)
%         cfg         = [];
%         cfg.layout  = 'CTF275.lay';
%         cfg.xlim    = [t t+0.1];
%         cfg.zlim    = [-1 1];
%         cfg.comment ='no';
%         ft_topoplotER(cfg,stat2plot{cnd_s});
%         %         title([lst_cnd{cnd_s} ' ' num2str(t*1000) 'ms']);
%     end
% end

cfg         = [];
cfg.layout  = 'CTF275.lay';
cfg.xlim    = [0 0.2];
cfg.zlim    = [-1 1];
cfg.comment ='no';
ft_topoplotER(cfg,stat2plot{1});

for cnd = 1:3
    gavg{cnd} = ft_timelockgrandaverage([],allsuj_GA{:,cnd});
end

cfg         = [];
cfg.layout  = 'CTF275.lay';
% cfg.xlim    = [0.29 0.31];
cfg.comment ='no';
cfg.zlim    = [-1 1];
ft_topoplotER(cfg,stat2plot{1});figure;
cfg.zlim    = [-30 30];
ft_topoplotER(cfg,gavg{1});figure;
ft_topoplotER(cfg,gavg{3});figure;

% stat                  = rmfield(stat,'cfg');
%
% clearvars -except stat allsuj_GA ;
%
% [min_p , p_val]         = h_pValSort(stat) ;
%
% stat2plot               = h_plotmyERFstat(stat,0.05);
% cfg                     = [];
% cfg.layout              = 'CTF275.lay';
% ft_topoplotER(cfg,stat2plot);
%
% sig_dis_chan = {'MLC16', 'MLC17', 'MLC24', 'MLC25', 'MLC31', 'MLC32', 'MLC41', 'MLC42', ...
%     'MLC53', 'MLC54', 'MLC55', 'MLC62', 'MLF66', 'MLF67', 'MLO14', 'MLP12', 'MLP22', 'MLP23',...
%     'MLP31', 'MLP32', 'MLP33', 'MLP34', 'MLP35', 'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP45', ...
%     'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT15', 'MLT16', 'MLT26'};
%
% % sig_dis_chan = {'MLC14', 'MLC15', 'MLC16', 'MLC17', 'MLC22', 'MLC23', 'MLC24', ...
% %     'MLC25', 'MLC31', 'MLC32', 'MLC41', 'MLC42', 'MLF56', 'MLF65', 'MLF66', ...
% %     'MLF67', 'MLP12', 'MLP23', 'MLP33', 'MLP34', 'MLP35', 'MLP42', 'MLP43', ...
% %     'MLP44', 'MLP45', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT12', 'MLT13', ...
% %     'MLT14', 'MLT15', 'MLT16', 'MLT24', 'MLT25', 'MLT26', 'MLT36'};
% %
% % sig_dis_chan2 = {'MLO14', 'MLP22', 'MLP31', 'MLP32', 'MLP33', 'MLP34', ...
% %     'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP52', 'MLP53', 'MLP54', ...
% %     'MLP55', 'MLP56', 'MLP57', 'MLT15', 'MLT16', 'MLT26', 'MLT27'};
%
%
% for ccue = 1:2
%     gavg{ccue} = ft_timelockgrandaverage([],allsuj_GA{:,ccue});
% end
%
% cfg=[];
% cfg.channel             = sig_dis_chan;
% cfg.avgoverchan         = 'yes';
% sig_dis_data{1}         = ft_selectdata(cfg,gavg{1});
% sig_dis_data{2}         = ft_selectdata(cfg,gavg{2});
%
% hold on
% plot(sig_dis_data{1}.time,sig_dis_data{1}.avg,'b','LineWidth',5) ;  xlim([-0.1 0.5]) ;ylim([-50 50])
% plot(sig_dis_data{2}.time,sig_dis_data{2}.avg,'r','LineWidth',5) ;  xlim([-0.1 0.5]) ;ylim([-50 50])
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')
%
% % cfg=[];
% % cfg.layout             = 'CTF275.lay';
% % cfg.channel            = sig_dis_chan2;
% % cfg.xlim               = [-0.1 0.6];
% % cfg.zlim               = [-10 10];
% % ft_singleplotER(cfg,gavg{:})
%
% % for ccue = 1:2
% %     figure;
% %     cfg=[];
% %     cfg.layout              = 'CTF275.lay';
% %     cfg.highlightchannel    = sig_dis_chan2;
% %     cfg.highlight           = 'on';
% %     cfg.highlightsymbol     = '.';
% %     cfg.highlightcolor      = [1 0 0];
% %     cfg.highlightsize       = 20;
% %     cfg.comment             = 'no';
% %     cfg.xlim                = [0.08 0.12];
% %     cfg.zlim                = [-70 70];
% %     ft_topoplotER(cfg,gavg{ccue});
% % end
%
% % left_common = {'MLO14', 'MLO24', 'MLO34', 'MLP43', 'MLP44', 'MLP54', 'MLP55', 'MLP56', 'MLT15', 'MLT16', 'MLT26', 'MLT27', 'MLT37', 'MLT47'};
% % right_common =  {'MRO34', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT25', 'MRT26', 'MRT27', 'MRT37'};
% %
% % cfg =[];
% % cfg.layout = 'CTF275.lay';
% % cfg.xlim = [-0.2 0.6];
% % cfg.zlim = [-30 30];
% % subplot(1,2,1)
% % cfg.channel = left_common;
% % ft_singleplotER(cfg,gavg{:}); legend('u','l','r')
% % title('Common');
% % subplot(1,2,2)
% % cfg.channel = right_common;
% % ft_singleplotER(cfg,gavg{:}); legend('u','l','r')
% % title('Common');
% %
% %
% % cfg             = [];
% % cfg.parameter   = 'avg';
% % cfg.operation   = 'x1-x2';
% % stat2plot{1}    = ft_math(cfg,ft_timelockgrandaverage([],allsuj_GA{:,1}),...
% %     ft_timelockgrandaverage([],allsuj_GA{:,2}));
% % stat2plot{2}    = ft_math(cfg,ft_timelockgrandaverage([],allsuj_GA{:,1}),...
% %     ft_timelockgrandaverage([],allsuj_GA{:,3}));
% % stat2plot{3}    = ft_math(cfg,ft_timelockgrandaverage([],allsuj_GA{:,2}),...
% %     ft_timelockgrandaverage([],allsuj_GA{:,3}));
% %
% % for cnd_s = 1:length(stat)
% %     cfg                     = [];
% %     cfg.latency             = [stat.time(1) stat.time(end)];
% %     stat2plot        = ft_selectdata(cfg,stat2plot);
% % end
% %
% % for cnd_s = 1:length(stat)
% %     stat.mask       = stat.prob < 0.05;
% %     stat2plot.avg   = stat2plot.avg .* stat.mask ;
% % end
% %
% % time_list = 0:0.05:0.6;
% %
% % for cnd_s = 1:length(stat)
% %     figure;
% %     for i = 1:(length(time_list))
% %
% %         subplot(4,4,i)
% %         cfg         = [];
% %         cfg.layout  = 'CTF275.lay';
% %         cfg.xlim    = [time_list(i) time_list(i)+0.05];
% %         cfg.zlim    = [-5 5];
% %         ft_topoplotER(cfg,stat2plot);
% %
% %     end
% % end
% %
% % for cnd = 1:size(allsuj_GA,2)
% %     gavg{cnd} = ft_timelockgrandaverage([],allsuj_GA{:,cnd});
% % end
% %
% % for c = 1:length(stat)
% %
% %     i = 0 ;
% %
% %     for x = 1:length(stat{c}.posclusters)
% %         if stat{c}.posclusters(x).prob < 0.05
% %             i = i + 1 ;
% %             [chan,tim]      = find(stat{c}.posclusterslabelmat == x);
% %             chan_list{c}{i} = unique(chan);
% %         end
% %     end
% %
% %     for x = 1:length(stat{c}.negclusters)
% %         if stat{c}.negclusters(x).prob < 0.05
% %             i = i + 1 ;
% %             [chan,tim]      = find(stat{c}.negclusterslabelmat == x);
% %             chan_list{c}{i} = unique(chan);
% %         end
% %     end
% %
% % end
% %
% % stat_list = {'UvL','UvR','LvR'};
% % cnd_list  = {'U','L','R'};
% % cnd_stat  = [1 2;1 3; 2 3];
% %
% % figure;
% % i = 0 ;
% %
% % for a = 1:size(chan_list,2)
% %     for b = 1:size(chan_list{a},2)
% %         i = i + 1;
% %         cfg =[];
% %         cfg.channel = chan_list{a}{b};
% %         cfg.xlim = [-0.2 0.6];
% %         cfg.zlim = [-30 30];
% %         subplot(2,4,i);
% %         ft_singleplotER(cfg,gavg{:});
% %         legend(cnd_list);
% %         title(stat_list{a});
% %     end
% % end
% %
% % for c = 1:3
% %     figure;
% %     cfg         = [];
% %     cfg.layout  = 'CTF275.lay';
% %     cfg.xlim    = 0:0.1:0.6;
% %     cfg.zlim    = [-30 30];
% %     ft_topoplotER(cfg,gavg{c});
% % end
% %
% % % figure;
% % % cfg         = [];
% % % cfg.layout  = 'CTF275.lay';
% % % cfg.xlim    = [-0.2 0.7];
% % % ft_multiplotER(cfg,gavg{:});
% % % legend({'u','l','r'})
% % %
% % % %
% % % % for cnd_s = 1:length(stat)
% % % %     figure;
% % % %     cfg         = [];
% % % %     cfg.layout  = 'CTF275.lay';
% % % %     ft_multiplotER(cfg,stat2plot);
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
% % %     'MLT14', 'MLT15', 'MLT16', 'MLT24', 'MLT25', 'MLT26', 'MRC51', 'MRC61', 'MRC63', 'MRP21', 'MZC02', 'MZC03', 'MZC04'};
% % %
% % % cfg         = [];
% % % cfg.channel  = vn_group;
% % % cfg.xlim    = [-0.2 0.7];
% % % ft_singleplotER(cfg,gavg{:});
% % % legend({'i-dis','u-dis'})