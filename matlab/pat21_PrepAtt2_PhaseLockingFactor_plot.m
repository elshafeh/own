clear ; clc ;

for sb = 1:14
    
    ext_essai   = '.m1000p2000.1t100Hz.fourier.mat';
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    lst_cue         = {'R','L','N'};
    
    for cnd = 1:2
        
        load(['../data/tfr/' suj '.' lst_cue{cnd} 'CnD.m1000p2000.1t100Hz.plvNoabs.mat']);
        
        allsuj_GA{sb,cnd}.label         = plf.label;
        allsuj_GA{sb,cnd}.freq          = plf.freq;
        allsuj_GA{sb,cnd}.time          = plf.time;
        allsuj_GA{sb,cnd}.dimord        = plf.dimord;
        allsuj_GA{sb,cnd}.powspctrm     = plf.plf;

    end
    
end

clearvars -except allsuj_GA

for cnd = 1:2
    
    gavg{cnd} = ft_freqgrandaverage([],allsuj_GA{:,cnd});
    figure;
    
    for chn = 1:length(gavg{cnd}.label)
        subplot(2,1,chn)
        
        cfg                 = [];
        cfg.channel         = chn;
        cfg.xlim            = [-0.1 1.5];
        cfg.ylim            = [4 15];
        cfg.zlim            = [0 0.5];
        ft_singleplotTFR(cfg,gavg{cnd});
        
    end
end