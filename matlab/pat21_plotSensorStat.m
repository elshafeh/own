clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/SensorAlphaStat.mat

for s = 1:4
    [min_p(s),p_val{s}] = h_pValSort(stat{s});
    stat2plot{s}        = h_plotStat(stat{2},0.05,'no');
end

for cnd_s = 4 %1:size(stat,2)
    
    ix = 0 ;
    for t = 0.2:0.1:0.9
        
        ix = ix + 1;
        
        subplot(3,3,ix)
        cfg                 = [];
        cfg.layout          = 'CTF275.lay';
        cfg.xlim            = [t t+0.1];
        cfg.ylim            = [7 15];
        cfg.zlim            = [-2 2];
        ft_topoplotTFR(cfg,stat2plot{cnd_s});
        
    end
end

for cnd_s = 4% 1:size(stat,2)
    for f = 7:15
        
        subplot(3,3,f-6)
        
        cfg                 = [];
        cfg.layout          = 'CTF275.lay';
        cfg.ylim            = [f f];
        cfg.zlim            = [-0.5 0.5];
        cfg.comment         = 'no';
        ft_topoplotTFR(cfg,stat2plot{1})
        title([num2str(f) 'Hz']);
        
    end
end