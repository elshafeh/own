clear ; clc ;

for sb = 1:14
    
    ext_essai   = '.m1000p2000.1t100Hz.fourier.mat';
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    fname_in = [suj ext_essai];
    fprintf('\nLoading %50s \n\n',fname_in);
    load(['../data/tfr/' fname_in]);
    
    big_freq        = freq ; clear freq ;
    
    lst_cue         = {'R','L','N'};
    
    for cnd = 1:2
        
        cfg                         = [];
        cfg.trials                  = h_chooseTrial(big_freq,cnd,0,1:4);
        freq                        = ft_selectdata(cfg,big_freq);
        
        angles_raw                  = angle(freq.fourierspctrm);
        angles_avg                  = squeeze(mean(angles_raw,1));
        angles_abs                  = abs(angles_avg);
        
        plf.label                   = freq.label ;
        plf.freq                    = freq.freq ;
        plf.time                    = freq.time ;
        plf.dimord                  = 'chan_freq_time';
        plf.plf                     = angles_avg ;

        %         plf.plfZ                    = .5.*log((1+angles_abs)./(1-angles_abs));
        
        save(['../data/tfr/' suj '.' lst_cue{cnd} 'CnD.m1000p2000.1t100Hz.plvNoabs.mat'],'plf');
        
        clear plf angles_*
        
    end
    
end