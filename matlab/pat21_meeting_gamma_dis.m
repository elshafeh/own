clear;clc;dleiftrip_addpath;

load ../data/yctot/stat/final_gamma_sensor_disfdis.mat;

[min_p, p_val]          = h_pValSort(stat) ;
stat2plot               = h_plotStat(stat,0.001,0.1);

twin  = 0.1;
tlist = -0.1:twin:0.6;

for t = 1:length(tlist)
    subplot(3,3,t)
    cfg                     = [];
    cfg.layout              = 'CTF275.lay';
    cfg.xlim                = [tlist(t) tlist(t)+twin];
    cfg.zlim                = [-1 1];
    cfg.marker              = 'off';
    ft_topoplotTFR(cfg,stat2plot);
end