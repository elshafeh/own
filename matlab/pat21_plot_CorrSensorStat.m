clear ; clc ;

% load ../data/yctot/stat/SensorCorrConditionCompare4Niehg.mat
% load('../data/yctot/stat/SensorCorrAgainstZeroSummary400t1200ms7t15Hz4Neigh.mat');
% load('../data/yctot/stat/ActvVBslSensorCorrSummary400t1200ms7t15Hz4Neigh.mat');

load('../data/yctot/stat/ActvBslCorr5t15.200t1200.mat');

clearvars -except stat

allsuj{1,1}.time = stat{1,1}.time;
allsuj{1,1}.freq = stat{1,1}.freq;

for cnd_r = 1:size(stat,1)
    for cnd_c = 1:size(stat,2)
        
        [min_p(cnd_r,cnd_c),p_val{cnd_r,cnd_c}]         = h_pValSort(stat{cnd_r,cnd_c});
        corr2plot{cnd_r,cnd_c}                          = h_plotStat(stat{cnd_r,cnd_c},0.05,'no');
        
    end
end

for cnd_r = 1%:size(stat,1)
    for cnd_c = 1%:size(stat,2)
        cfg.frequency                   = [7 15];
        cfg.avgoverfreq                 = 'yes';
        corr2plotavgoverfreq{cnd_r,cnd_c}     = ft_selectdata(cfg,corr2plot{cnd_r,cnd_c} );
    end
end

for cnd_r = 1%:size(stat,1)
    %     for cnd_c = 1%:size(stat,2)
    
    if min_p(cnd_r) < 0.05 && min_p(cnd_r) > 0
        figure;
        
        for a = 14:length(allsuj{1,1}.time)
            
            subplot(2,4,a-13)
            
            cfg             = [];
            cfg.layout      = 'CTF275.lay';
            cfg.xlim        = [allsuj{1,1}.time(a) allsuj{1,1}.time(a)];
            cfg.zlim        = [-3 3];
            cfg.comment     = 'no';
            ft_topoplotTFR(cfg,corr2plotavgoverfreq{cnd_r});
            %                 title([num2str(cnd_r) ',' num2str(cnd_c) ' ' num2str(round(allsuj{1,1}.time(a)*1000)) 'ms']);
            title([num2str(round(allsuj{1,1}.time(a)*1000))]);
            
        end
    end
    %     end
end

for cnd_r = 1:2%:size(stat,1)
    %     for cnd_c = 1%:size(stat,2)
    
    cfg                                     = [];
    cfg.latency                             = [0.9 1.1];
    cfg.avgovertime                         = 'yes';
    corr2plotavgovertime{cnd_r}       = ft_selectdata(cfg,corr2plot{cnd_r} );
    
    %     end
end

for cnd_r = 1%:2
    %     for cnd_c = 1%:size(stat,2)
    
    if min_p(cnd_r) < 0.05 && min_p(cnd_r) > 0
        
        figure;
        
        for a = 1:length(allsuj{1,1}.freq)
            
            subplot(4,3,a)
            
            cfg             = [];
            cfg.layout      = 'CTF275.lay';
            cfg.ylim        = [allsuj{1,1}.freq(a) allsuj{1,1}.freq(a)];
            cfg.zlim        = [-5 5];
            cfg.comment     = 'no';
            ft_topoplotTFR(cfg,corr2plotavgovertime{cnd_r});
            %                 title([num2str(cnd_r) ',' num2str(cnd_c) ' ' num2str(allsuj{1,1}.freq(a)) 'Hz']);
            
            title([num2str(allsuj{1,1}.freq(a)) 'Hz']);
            
        end
    end
    %     end
end