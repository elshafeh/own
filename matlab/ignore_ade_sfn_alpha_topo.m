clear ; clc;

addpath(genpath('kakearney-boundedline'));

load ../data/goodsubjects-07-Oct-2019.mat;

for nm = 1:length(list_modality)
    
    list_suj                                = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        suj                                 = list_suj{ns};
        modality                            = list_modality{nm};
        
        fname                               = ['../data/' suj '_sfn.fft_' modality '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        fname                               = ['../data/' suj '_sfn.fft_' modality '.peak.mat'];
        load(fname);
        
        cfg                                 = [];
        cfg.frequency                       = [alpha(1)-1 alpha(1)+1];
        cfg.avgoverrpt                      = 'yes';
        freq_slct                           = ft_selectdata(cfg,freq);
        freq_slct.freq                      = 1:length(freq_slct.freq);
        
        data_sub{nm}{ns,1}                  = freq_slct; clear freq_slct freq;
        
    end
end

clearvars -except data_sub;

subplot(2,1,1)
cfg             = [];
cfg.layout      = 'CTF275.lay';
ft_topoplotTFR(cfg,ft_freqgrandaverage([],data_sub{1}{:,1}));

subplot(2,1,2)
cfg             = [];
cfg.layout      = 'CTF275.lay';
ft_topoplotTFR(cfg,ft_freqgrandaverage([],data_sub{2}{:,1}));