clear ; clc ;

load ../data/yctot/stat/5t15.2001100.SensorAlphaStat.mat

for cnd_s = 1:4
    [min_p(cnd_s),p_val{cnd_s}] = h_pValSort(stat{cnd_s});
end

for cnd_s = 1:4
    corr2plot{cnd_s}                    = h_plotStat(stat{cnd_s},0.09,'no');
end

for cnd_s = 1:4
    cfg.frequency                   = [7 15];
    cfg.avgoverfreq                 = 'yes';
    corr2plotavgoverfreq{cnd_s}     = ft_selectdata(cfg,corr2plot{cnd_s} );
end

for cnd_s = 1:4
    
    if min_p(cnd_s) < 0.09 && min_p(cnd_s) > 0
        figure;
        
        for a = 1:length(stat{1}.time)
            
            subplot(5,4,a)
            
            cfg             = [];
            cfg.layout      = 'CTF275.lay';
            cfg.xlim        = [stat{1}.time(a) stat{1}.time(a)];
            cfg.zlim        = [-1 1];
            cfg.comment     = 'no';
            ft_topoplotTFR(cfg,corr2plotavgoverfreq{cnd_s});
            title(num2str(stat{1}.time(a) * 1000))
        end
    end
end

for cnd_s = 1:4
    
    cfg                                     = [];
    cfg.latency                             = [0.8 1.1];
    cfg.avgovertime                         = 'yes';
    corr2plotavgovertime{cnd_s}             = ft_selectdata(cfg,corr2plot{cnd_s} );
    
end

for cnd_s = 1:4
    
    if min_p(cnd_s) < 0.05 && min_p(cnd_s) > 0
        
        figure;
        
        for a = 1:length(stat{1}.freq)
            
            subplot(4,3,a)
            
            cfg             = [];
            cfg.layout      = 'CTF275.lay';
            cfg.ylim        = [stat{1}.freq(a) stat{1}.freq(a)];
            cfg.zlim        = [-1.5 1.5];
            cfg.comment     = 'no';
            ft_topoplotTFR(cfg,corr2plotavgovertime{cnd_s});
            title([num2str(stat{1}.freq(a)) 'Hz']);
            
        end
    end
end