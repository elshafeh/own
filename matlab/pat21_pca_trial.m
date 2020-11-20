clear ; clc ; dleiftrip_addpath ;

% load ../data/yctot/gavg/new.1RCnD.2LCnD.3NCnDRT.4NCnDLT.pe.mat;
load ../data/yctot/gavg/VN.CnD.eeg.pe.mat;

for sb = 1:14
    
    avg{sb}             = ft_timelockgrandaverage([],allsuj{sb,:});
    
    cfg                 = [];
    cfg.baseline        = [-0.1 0];
    avg{sb}             = ft_timelockbaseline(cfg,avg{sb});
    
    cfg.latency         = [0 1.1];
    avg{sb}             = ft_selectdata(cfg,avg{sb});
    
end

gavg                    =  ft_timelockgrandaverage([],avg{:});

cfg                     = [];
cfg.method              = 'pca';
comp                    = ft_componentanalysis(cfg, gavg);

cfg                     = [];
cfg.component           = 1:10;
cfg.layout              = 'elan_lay.mat';
cfg.comment             = 'no';
cfg.marker              = 'off';
ft_topoplotIC(cfg, comp)

cfg                     = [];
cfg.channel             = 1:5;
cfg.viewmode            = 'component';
cfg.layout              = 'elan_lay.mat';
ft_databrowser(cfg, comp)