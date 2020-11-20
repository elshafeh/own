clear ; clc ; 

load ../data/yctot/stat/LN.nDT.sensor.mat

for cnd_f = 1:size(stat,2)
    [min_p(cnd_f), p_val{cnd_f}]      = h_pValSort(stat{cnd_f}) ;
    stat2plot{cnd_f}                  = h_plotStat(stat{cnd_f},0.3,'no');
end

for cnd_f = 1:size(stat,2)
    
    figure;
    cfg         =   [];
    cfg.xlim    =   -0.2:0.1:0.6;
    cfg.zlim    =   [-2 2];
    cfg.layout  = 'CTF275.lay';
    ft_topoplotTFR(cfg,stat2plot{cnd_f});
    
end