clear;clc;dleiftrip_addpath;

load ../data/yctot/stat/ActvBaseline4Neigh7t15Hz200t2000ms.mat
load ../data/yctot/gavg/CnD5t18.mat ;

[min_p , p_val]         = h_pValSort(stat) ;

stat2plot               = h_plotStat(stat,0.002,0.008);

cfg                     = [];
cfg.xlim                = [0.2 1];
cfg.ylim                = [7 15];
cfg.zlim                = [-1.2 1.2];
cfg.layout              = 'CTF275.lay';
cfg.comment             = 'no';
cfg.colorbar            = 'no';
cfg.marker              = 'off';
ft_topoplotTFR(cfg,stat2plot);
