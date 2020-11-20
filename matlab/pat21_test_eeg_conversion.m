clear ; clc ;

suj = 'yc1' ; 

load(['../data/' suj '/elan/' suj '.CnD.eeg.mat']);

avg = ft_timelockanalysis([],data_elan) ;

cfg             =   [];
cfg.lpfilter    =   'yes' ;
cfg.lpfreq      =   20;
avg             =   ft_preprocessing(cfg,avg) ;

cfg = [];
cfg.baseline = [-0.1 0];
avg          = ft_timelockbaseline(cfg,avg);

cfg         = [];
cfg.layout  = 'elan_lay.mat';
cfg.xlim    = [0.6 0.8];
cfg.zlim    = [-3 3];
ft_topoplotER(cfg,avg);