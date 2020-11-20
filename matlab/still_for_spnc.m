clear ; clc ; 

suj                     = 'yc1';
fname_in                = ['../data/paper_data/' suj '.CnD.all.wav.1t30Hz.m3000p3000.mat'];
load(fname_in);

freq.powspctrm(:)       = 0 ;

cfg                     = [];
cfg.layout              = 'CTF275.lay';
cfg.marker              = 'off';
cfg.comment             = 'no';
cfg.highlight           = 'on';
cfg.highlightchannel    = {'MLO11', 'MLO12', 'MLO21', 'MLO22', 'MLO23', 'MLO31', ...
    'MLO32', 'MLO41', 'MLO42', 'MLO51', 'MLO52', 'MRO11', 'MRO12', ...
    'MRO21', 'MRO22', 'MRO23', 'MRO31', 'MRO32', 'MRO33', 'MRO41', ...
    'MRO42', 'MRO43', 'MRO51', 'MRO52', 'MZO01', 'MZO02', 'MZO03'};

cfg.highlightsize       = 10;
cfg.highlightsymbol     = 'x';
ft_topoplotTFR(cfg,freq);
colormap(white)

saveas(gcf,'../images/empty_occ_sens.svg'); close all;
