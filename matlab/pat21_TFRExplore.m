clear ; clc ;

load('../data/yctot/gavg/bp.gavg.mat');

cfg                 = [];
cfg.baseline        = [-2.6 -2.2];
cfg.baselinetype    = 'relchange';
Gavg                = ft_freqbaseline(cfg,Gavg{1});

ix = 0 ;

for t = -2.8:0.2:0.6
    
    ix = ix + 1; 
    
    subplot(5,4,ix)
    
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    cfg.xlim    = [t t+0.2];
    cfg.ylim    = [12 14];
    cfg.comment = 'no' ;
    ft_topoplotTFR(cfg,Gavg);
    
end