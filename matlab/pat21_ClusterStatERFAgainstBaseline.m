clear ; clc ; dleiftrip_addpath ;

fprintf('Loading Data\n');
load ../data/yctot/gavg/Concat_DisfDis.pe.mat
load ../data/yctot/stat/disversusfdisconcatstat.mat
fprintf('Done!\n');

% [design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;
%
% cfg                   = [];
% cfg.channel           = 'MEG';
% cfg.latency           = [-0.2 0.7] ;
% cfg.method            = 'montecarlo';     % Calculation of the significance probability
% cfg.statistic         = 'depsamplesT';    % T test
% cfg.correctm          = 'cluster';        % MCP correction
% cfg.clusteralpha      = 0.05;             % First Threshold
% cfg.clusterstatistic  = 'maxsum';
% cfg.minnbchan         = 4;
% cfg.tail              = 0;
% cfg.clustertail       = 0;
% cfg.alpha             = 0.025;
% cfg.numrandomization  = 1000;
% cfg.neighbours        = neighbours;
% cfg.design            = design;
% cfg.uvar              = 1;
% cfg.ivar              = 2;
% stat                  = ft_timelockstatistics(cfg, allsuj{:,1}, allsuj{:,2});

[min_p , p_val]       = h_pValSort(stat) ;

cfg             = [];
cfg.parameter   = 'avg';
cfg.operation   = 'x1-x2';
stat2plot       = ft_math(cfg,ft_timelockgrandaverage([],allsuj{:,1}),ft_timelockgrandaverage([],allsuj{:,2}));

cfg = [];
cfg.baseline = [-0.2 -0.1];
stat2plot = ft_timelockbaseline(cfg,stat2plot);

% cfg                     = [];
% cfg.latency             = [stat.time(1) stat.time(end)];
% stat2plot               = ft_selectdata(cfg,stat2plot);
%
% stat.mask       = stat.prob < 0.1;
% stat2plot.avg   = stat2plot.avg .* stat.mask ;

% time_list = stat.time(1):0.05:stat.time(end);

% time_list = 0:0.05:0.7;
% 
% figure;
% 
% for i = 1:(length(time_list))
%     
%     subplot(3,5,i)
%     cfg         = [];
%     cfg.layout  = 'CTF275.lay';
%     cfg.xlim    = [time_list(i) time_list(i)+0.05];
%     cfg.zlim    = [-30 30];
%     ft_topoplotER(cfg,stat2plot);
%     
% end
%
% cfg         = [];
% cfg.layout  = 'CTF275.lay';
% cfg.xlim    = [0.4 0.45];
% cfg.zlim    = [-40 40];
% ft_topoplotER(cfg,stat2plot);

gp{1} = {'MLT11', 'MLT12', 'MLT13', 'MLT14', 'MLT22', 'MLT23', 'MLT24', 'MLT25', 'MLT32', ...
    'MLT33', 'MLT34', 'MLT35', 'MLT42', 'MLT43', 'MLT44', 'MLT53'}; % left up;

gp{2} = {'MRT11', 'MRT12', 'MRT21', 'MRT22', 'MRT23', 'MRT24', 'MRT32', 'MRT33', 'MRT41', 'MRT42'}; % right up;

gp{3} = {'MLO13', 'MLO14', 'MLO23', 'MLO24', 'MLO33', 'MLO34', 'MLO43', 'MLO44', 'MLT27', 'MLT37', 'MLT47', 'MLT57'}; % left down

gp{4} = {'MRO13', 'MRO14', 'MRO23', 'MRO24', 'MRO33', 'MRO34', 'MRP33', 'MRP42', 'MRP43', ...
    'MRP44', 'MRP53', 'MRP54', 'MRP55', 'MRP56', 'MRT15', 'MRT16', 'MRT26', 'MRT27', 'MRT37', 'MRT47'}; % right down

gp{5} = {'MLC12', 'MLC13', 'MLC14', 'MLC15', 'MLC21', 'MLC22', ...
    'MLC23', 'MLC41', 'MLC52', 'MLF45', 'MLF54', 'MLF55', ...
    'MLF62', 'MLF63', 'MLF64', 'MLF65'}; % central left 

gp{6} = {'MRC12', 'MRC13', 'MRC14', 'MRC21', 'MRF35', 'MRF45', ...
    'MRF46', 'MRF53', 'MRF54', 'MRF55', 'MRF61', 'MRF62', 'MRF63', 'MRF64'}; % central right

gp{7} = {'MRO22', 'MRO23', 'MRO32', 'MRO33', 'MRO34', 'MRO42', ...
    'MRO43', 'MRO44', 'MRO53', 'MRT47', 'MRT57'}; % occ right

gp{8} = {'MLO23', 'MLO32', 'MLO33', 'MLO34', 'MLO43', 'MLO44', ...
    'MLO53', 'MLT47', 'MLT57', 'MRO22', 'MRO23', 'MRO32', 'MRO33', ...
    'MRO34', 'MRO42', 'MRO43', 'MRO44', 'MRO53', 'MRT47', 'MRT57'}; % occ left

gp_list = {'left up','right up','left down','right down',...
    'central left','central right','occ right','occ left'};

% for c = 1:8
%     subplot(4,2,c)
%     cfg         = [];
%     cfg.channel = gp{c};
%     cfg.xlim    = [-0.2 0.7];
%     cfg.ylim    = [-70 120];
%     ft_singleplotER(cfg,stat2plot);
%     vline(0,'-k');
%     title(gp_list{c});
% end

slctappnd = [];

for c = 1:8
    cfg=[];
    cfg.channel         = gp{c};
    cfg.avgoverchan     = 'yes';
    slctchan{c}         =  ft_selectdata(cfg,stat2plot);
    slctchan{c}.label   = gp_list(c);
    slctappnd(c,:)      = slctchan{c}.avg;
end

% slctappnd = -1 * slctappnd;

plot(stat2plot.time,stat2plot.avg,'LineWidth',2)
% plot(stat2plot.time,slctappnd,'LineWidth',2)
xlim([-0.2 0.7]);
% ylim([-150 80])
% legend(gp_list)
% h_legend=legend(gp_list);
% set(h_legend,'FontSize',14);
vline(0,'--k')
hline(0,'--k')
set(gca,'fontsize',14);