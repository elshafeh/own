function [allpeaks] = h_virt_findpeak(freq,peak_window)


cfg                     = [];
cfg.latency             = peak_window;
cfg.avgovertime         = 'yes';
cfg.nanmean             = 'yes';
freq                    = ft_selectdata(cfg,freq);
freq.dimord             = 'chan_freq';

allpeaks                = [];

for nchan = 1:length(freq.label)
    
    tmp                 = freq;
    tmp.powspctrm       = tmp.powspctrm(nchan,:,:);
    tmp.label           = tmp.label(nchan);
    
    cfg                 = [];
    cfg.for             = [7 14];
    cfg.method          = 'maxabs' ;
    apeak               = alpha_peak(cfg,tmp);
    apeak               = apeak(1);
    
    tmp.freq            = round(tmp.freq);
    
    cfg                 = [];
    cfg.method          = 'linear' ;
    cfg.foi             = [15 30];
    bpeak               = alpha_peak(cfg,tmp);
    bpeak               = bpeak(1);
    
    allpeaks(nchan,1)   = apeak;
    allpeaks(nchan,2)   = bpeak; clear  apeak bpeak;
        
end