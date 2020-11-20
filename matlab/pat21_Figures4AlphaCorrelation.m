clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/Correlation.p0p1200ms.7t15Hz.mat;

stat.mask = stat.prob < 0.05 ;
nwMask    = mean(mean(stat.mask .* stat.stat,3),2) ;
lst_chan  = find(nwMask < -0.11);

load ../data/yctot/gavg/CnD5t18.mat ; freq = frqGA ; clear frqGA

cfg                     = [];
cfg.layout              = 'CTF275.lay' ;
cfg.xlim                = [0.9 1.2];
cfg.ylim                = [10 15] ;
cfg.zlim                = [-0.2 0.2] ;
cfg.highlight           = 'on';cfg.highlightchannel    =  lst_chan;cfg.highlightsymbol     = '.';
cfg.highlightcolor      = [0 0 0];cfg.highlightsize       = 15;
cfg.comment             = 'no';cfg.marker              = 'off';
cfg.colorbar            = 'yes';
subplot(1,2,1)
ft_topoplotTFR(cfg,freq) ;

lstSin = {'MRO13', 'MRO14', 'MRO24', 'MRP34', 'MRP43', 'MRP44', 'MRP54', ...
    'MRP55', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT25', ...
    'MRT26', 'MRT27', 'MRT36', 'MRT37'};

cfg                     = []; cfg.layout              = 'CTF275.lay' ;
cfg.xlim                = [0 1.4]; cfg.ylim = [7 15] ; cfg.zlim = [-0.2 0.2] ;
cfg.channel             =  lstSin;
cfg.comment             = 'no'; cfg.colorbar            = 'no';
subplot(1,2,2)
ft_singleplotTFR(cfg,freq) ;
hline(10,'k-','');hline(15,'k-','');vline(0.9,'k-','');title('');


