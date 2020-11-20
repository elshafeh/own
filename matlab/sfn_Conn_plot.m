clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

suj_list           = [1:4 8:17] ;

for sb = 1:length(suj_list)
    
    suj                 = ['yc' num2str(suj_list(sb))] ;
    ext_data            = 'CnD.PaperAudVisTD.1t20Hz.m800p2000msCov.WavFourrierMinEvoked.mat';
    fname               = ['../data/conn/' suj '.' ext_data];
    
    fprintf('Loading %s\n',fname);
    load(fname);
    
    freq                = ft_freqdescriptives([],freq);
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg,freq);
    
    allsuj_freq{sb}     = freq; clear freq;
    
end

clearvars -except allsuj_freq

grand_avg               = ft_freqgrandaverage([],allsuj_freq{:});

for nchan = 1:length(grand_avg.label)
    subplot(4,4,nchan)
    
    cfg             = [];
    cfg.xlim        = [-0.2 1.2];
    cfg.ylim        = [4 20];
    cfg.zlim        = [-0.3 0.3];
    cfg.channel     = nchan;
    ft_singleplotTFR(cfg,grand_avg);
    
    colormap(brewermap(256, '*RdYlBu'));
    
end