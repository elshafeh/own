% Run Non-parametric cluster based permutation tests on Cue/Dis Locked

% Load data

clear ; clc ; 

% load ../data/yctot/gavg/new.1RnDT.2LnDT.3NnRT.4NnLT.pe.mat
% load ../data/yctot/gavg/new.1RCnD.2LCnD.3NCnDRT.4NCnDLT.pe.mat

% load ../data/yctot/gavg/D123.1.Dis.2.fDis.pe.mat;
load ../data/yctot/gavg/VN_DisfDis.pe.mat

for sb = 1:size(allsuj,1)
    
    %     allsuj_GA{sb,2}         = allsuj{sb,1};
    %     allsuj_GA{sb,1}         = ft_timelockgrandaverage([],allsuj{sb,2},allsuj{sb,3});    
    %         cfg                 = [];
    %         cfg.baseline        = [-0.1 0];
    %         allsuj_GA{sb,cnd}   = ft_timelockbaseline(cfg,allsuj{sb,cnd});
    
    for cnd = 1:size(allsuj,3)
        
        avg                  = allsuj{sb,1,cnd};
        atcv                 = allsuj{sb,1,cnd}.avg;
        bsl                  = allsuj{sb,2,cnd}.avg;
        
        avg.avg              = atcv - bsl; clear atcv bsl ;
        
        allsuj_GA{sb,cnd}    = avg ; clear avg ;
        
    end
    
end

clearvars -except allsuj_GA

% Run permutation

[design,neighbours]   = h_create_design_neighbours(14,allsuj_GA{1,1},'meg','t'); clc;

cfg                   = [];
cfg.channel           = 'MEG';
cfg.latency           = [-0.1 0.5] ;
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 3;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.design            = design;
cfg.uvar              = 1;
cfg.ivar              = 2;

stat{1}               = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
% stat{2}               = ft_timelockstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,3});
% stat{3}               = ft_timelockstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,3});

clearvars -except stat allsuj_GA ;

for cnd_s = 1:length(stat)
    [min_p(cnd_s) , p_val{cnd_s}]         = h_pValSort(stat{cnd_s}) ;
end

for cnd_s = 1:length(stat)
    stat{cnd_s}.mask        = stat{cnd_s}.prob < 0.12;
    stat2plot{cnd_s}        = allsuj_GA{1,1};
    stat2plot{cnd_s}.time   = stat{cnd_s}.time;
    stat2plot{cnd_s}.avg    = stat{cnd_s}.mask .* stat{cnd_s}.stat;
end

for cnd_s = 1:length(stat)
    figure;
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    %     cfg.xlim    = -0.1:0.1:0.5;
    cfg.zlim    = [-1 1];
    cfg.comment ='no';
    cfg.marker  = 'off';
    ft_topoplotER(cfg,stat2plot{cnd_s});
end

% lst_cnd = {'UminusL','UminusR','LminusR'};

for cnd_s = 1:length(stat)
    figure;
    i = 0;
    for t = 0:0.1:0.5
        i = i + 1;
        subplot(3,2,i)
        cfg         = [];
        cfg.layout  = 'CTF275.lay';
        cfg.xlim    = [t t+0.1];
        cfg.zlim    = [-1 1];
        cfg.comment ='no';
        ft_topoplotER(cfg,stat2plot{cnd_s});
        %         title([lst_cnd{cnd_s} ' ' num2str(t*1000) 'ms']);
    end
end

for cnd = 1:4   
    gavg{cnd} = ft_timelockgrandaverage([],allsuj_GA{:,cnd});
end

figure;
cfg         = [];
cfg.layout  = 'CTF275.lay';
cfg.xlim    = [0.11 0.21];
cfg.comment ='no';
cfg.marker  = 'off';
cfg.zlim    = [-2 2];
ft_topoplotER(cfg,stat2plot{1});
cfg.zlim    = [-55 55];
figure;
ft_topoplotER(cfg,gavg{1});
figure;
ft_topoplotER(cfg,gavg{3});

cfg=[];
cfg.channel = {'MRC13', 'MRC14', 'MRC22', 'MRF34', 'MRF35', 'MRF44',...
    'MRF45', 'MRF46', 'MRF52', 'MRF53', 'MRF54',...
    'MRF55', 'MRF62', 'MRF63', 'MRF64', 'MRF65'};

% cfg.channel = {'MRC13', 'MRC14', 'MRC15', 'MRC16', 'MRC17', 'MRC22',...
%     'MRC23', 'MRC24', 'MRC25', 'MRC31', 'MRC32', 'MRC42', 'MRF35', ...
%     'MRF45', 'MRF46', 'MRF53', 'MRF54', 'MRF55', 'MRF56', 'MRF62', ...
%     'MRF63', 'MRF64', 'MRF65', 'MRF66', 'MRF67', 'MRP23', 'MRP35', 'MRP45', 'MRT13'};
cfg.avgoverchan = 'yes';
gavg_slct{1} = ft_selectdata(cfg,gavg{1});
gavg_slct{3} = ft_selectdata(cfg,gavg{3});

figure;
hold on;
rectangle('Position',[0.11 -30 0.1 60]);
plot(gavg_slct{1}.time,[gavg_slct{1}.avg;gavg_slct{3}.avg],'LineWidth',3) ;
xlim([-0.1 0.6]);
ylim([-30 30]);
vline(0,'--k');
hline(0,'-k');
legend({'INF','UNF'})
set(gca,'XAxisLocation','origin')
set(gca,'fontsize',18)
set(gca,'FontWeight','bold');

% % for cnd_s = 1:length(stat)
% %     stat{cnd_s} = rmfield(stat{cnd_s},'cfg');
% % end