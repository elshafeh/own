clear ; clc ;


load('../data/yctot/gavg/CnD5t18.mat');

cfg         = [];
cfg.xlim    = [1.1 1.5];
cfg.layout  = 'CTF275.lay';
cfg.ylim    = [8 10];
cfg.comment = 'no';
cfg.zli     = [-0.1 0.1];
ft_topoplotTFR(cfg,frqGA);
