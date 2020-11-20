clear ; clc ; dleiftrip_addpath ; close all ;

for a = 1:14
    
    suj_list                                = [1:4 8:17];
    suj                                     = ['yc' num2str(suj_list(a))];
    extName                                 = '.CnD.all.wav.40t150Hz.m2000p2000.MinusEvoked.mat' ;
    fname                                   = ['../data/tfr/' suj extName];
        
    fprintf('Loading %30s\n',fname);  load(fname);
    
    cfg                                     = [];
    cfg.baseline                            = [-0.2 -0.1];
    cfg.baselinetype                        = 'relchange';
    allsuj_GA{a}                            = ft_freqbaseline(cfg,freq);
    clear freq

end

clearvars -except allsuj_GA ;

gavg        = ft_freqgrandaverage([],allsuj_GA{:,:}); clc ;

cfg         = [];
cfg.layout  = 'CTF275.lay';
cfg.xlim    = [0.1 0.5];
cfg.zlim    = [-0.05 0.05];
cfg.comment ='no';
cfg.marker  = 'off';
cfg.ylim    = [60 140];
ft_topoplotER(cfg,gavg);