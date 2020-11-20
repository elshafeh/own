clear ; clc ;  dleiftrip_addpath ;

% load ../data/yctot/gavg/new.1RnDT.2LnDT.3NnRT.4NnLT.pe.mat
% load ../data/yctot/gavg/new.1RCnD.2LCnD.3NCnDRT.4NCnDLT.pe.mat
% load ../data/yctot/gavg/new.1RnDT.2LnDT.3NnRT.4NnLT.pe.mat ;
% load ../data/yctot/gavg/D123.1.Dis.2.fDis.pe.mat;

load ../data/yctot/gavg/VN_DisfDis.pe.mat

stock_suj = allsuj ; clear allsuj;

for sb = 1:14
    
    for cnd = 1:2 %size(allsuj,2)
        
        avg                  = stock_suj{sb,1,cnd};
        atcv                 = stock_suj{sb,1,cnd}.avg;
        bsl                  = stock_suj{sb,2,cnd}.avg;
        
        avg.avg              = atcv - bsl; clear atcv bsl ;
        
        %         cfg                 = [];
        %         cfg.baseline        = [-0.15 0.05];
        %         avg                 = ft_timelockbaseline(cfg,allsuj{sb,cnd});
        
        cfg                 = [];
        cfg.method          = 'amplitude';
        allsuj{sb,cnd}      = ft_globalmeanfield(cfg,avg);
        
        clear avg gfp ;
    end
    
end

clearvars -except allsuj;

[design,neighbours]     = h_create_design_neighbours(14,allsuj{1,1},'gfp','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.tail                = 0;cfg.clustertail         = 0;
cfg.numrandomization    = 1000;cfg.design              = design;cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;cfg.minnbchan           = 0;

cfg.latency             = [-0.1 0.5];

stat{1}                 = ft_timelockstatistics(cfg, allsuj{:,1}, allsuj{:,2});
% stat{2}                 = ft_timelockstatistics(cfg, allsuj{:,1}, allsuj{:,3});
% stat{3}                 = ft_timelockstatistics(cfg, allsuj{:,2}, allsuj{:,3});

% stat{4}                 = ft_timelockstatistics(cfg, allsuj{:,2}, allsuj{:,3});
% stat{5}                 = ft_timelockstatistics(cfg, allsuj{:,2}, allsuj{:,4});
% stat{6}                 = ft_timelockstatistics(cfg, allsuj{:,3}, allsuj{:,4});

for cnd_s = 1:length(stat)
    [min_p(cnd_s),p_val{cnd_s}]           = h_pValSort(stat{cnd_s});
end

for cnd_s = 1:length(stat)
    stat{cnd_s}.mask = stat{cnd_s}.prob < 0.15;
    gfp2plot(cnd_s,:) = stat{cnd_s}.mask .* stat{cnd_s}.stat;
end

% lst_cnd = {'RmL','RmNR','RmNL','LmNR','LmNL','NRmNL'};
% lst_cnd = {'1m2','1m3','2m3'};

i = 0 ;

for cnd_s = 1:length(stat)
    i = i + 1;
    subplot(1,3,i)
    plot(stat{cnd_s}.time,gfp2plot(cnd_s,:));
    ylim([-7 7]);
    xlim([stat{cnd_s}.time(1) stat{cnd_s}.time(end)]);
    %     title(lst_cnd{cnd_s});
end

for cnd = 1:4
    gavg{cnd} = ft_timelockgrandaverage([],allsuj{:,cnd});
end

plot(gavg{1}.time,[gavg{1}.avg;gavg{2}.avg;gavg{3}.avg;gavg{4}.avg]);  
xlim([-0.1 0.5]);