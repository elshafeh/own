clear ; clc ; 

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    list_cues    = {'NCnD','LCnD','RCnD'};
    list_method  = 'ndPAC';
    list_time    = {'m400m200','m200m0','p0p200','p200p400','p400p600','p600p800','p800p1000',...
        'p1000p1200','p1200p1400','p1400p1600','p1600p1800'};
    list_norm    = 'NoNorm';
    list_chan    = {'audL','audR','RIPS'};
    
    for xcue = 1:length(list_cues)
        
        allsuj_GA{sb,xcue}.avg                    = zeros(length(list_chan),length(list_time));
        allsuj_GA{sb,xcue}.time                   = -0.4:0.2:1.6;
        allsuj_GA{sb,xcue}.label                  = list_chan;
        allsuj_GA{sb,xcue}.dimord                 = 'chan_time';
        
        for xtime = 1:length(list_time)
            
            load(['../data/python_data/' suj '.' list_cues{xcue} '.' list_time{xtime} '.' list_method '.ShuAmp' '.' list_norm '.100perm.mat'])
            
            x1                                     = find(py_pac.vec_amp==58);
            x2                                     = find(py_pac.vec_amp==70);
            y1                                     = find(py_pac.vec_pha==9);
            y2                                     = find(py_pac.vec_pha==10);

            py_pac.xpac                            = squeeze(py_pac.xpac);
            py_pac.xpac                            = squeeze(mean(py_pac.xpac,3));
            py_pac.xpac                            = permute(py_pac.xpac,[3 1 2]);
            
            allsuj_GA{sb,xcue}.avg(:,xtime)         = mean(squeeze(mean(py_pac.xpac(:,x1:x2,y1:y2),3)),2);
            act                                     = allsuj_GA{sb,xcue}.avg(:,xtime);
            bsl                                     = allsuj_GA{sb,xcue}.avg(:,1);
            
            
            allsuj_GA{sb,xcue}.avg(:,xtime)         = act-bsl;
            
        end
        
    end
end

clearvars -except allsuj_GA list_*;

[design,neighbours]   = h_create_design_neighbours(14,allsuj_GA{1},'virt','anova'); clc;

cfg                   = [];
cfg.latency           = [0 1.6];
cfg.method            = 'montecarlo';
cfg.statistic         = 'ft_statfun_depsamplesFunivariate';%'depsamplesT';
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 0;
cfg.alpha             = 0.025;
cfg.tail              = 0;
cfg.clustercritval    = 0.05;
cfg.clustertail       = 0;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.design            = design;
cfg.uvar              = 1;
cfg.ivar              = 2;

stat{1}               = ft_timelockstatistics(cfg, allsuj_GA{:,1},allsuj_GA{:,2}, allsuj_GA{:,3});
stat{2}               = ft_timelockstatistics(cfg, allsuj_GA{:,3}, allsuj_GA{:,1});
stat{3}               = ft_timelockstatistics(cfg, allsuj_GA{:,3}, allsuj_GA{:,2});

for cnd_s = 1:length(stat)
    [min_p(cnd_s),p_val{cnd_s}]           = h_pValSort(stat{cnd_s});
end

for cnd_s = 1:length(stat)
    
    stat{cnd_s}.mask             = stat{cnd_s}.prob < 0.3;
    stat2plot{cnd_s}.time        = stat{cnd_s}.time;
    stat2plot{cnd_s}.label       = stat{cnd_s}.label;
    stat2plot{cnd_s}.avg         = stat{cnd_s}.stat .* stat{cnd_s}.mask ;
    stat2plot{cnd_s}.dimord      = 'chan_time';
    
end

for cnd_s = 1:length(stat)
    figure;
    for chan = 1:3
        subplot(1,3,chan)
        plot(stat2plot{cnd_s}.time,stat2plot{cnd_s}.avg(chan,:));
        xlim([stat2plot{cnd_s}.time(1) stat2plot{cnd_s}.time(end)])
    end
end