clear ;

for ns = [1:33 35:36 38:44 46:51]
    
    fname                                   = ['../data/tf/sub' num2str(ns) '.sess12.allback.1t30Hz.1HzStep.AvgTrials.4peak.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    peak_window                             = [-1 0];
    peak_name                               = ['m' num2str(abs(peak_window(1)*1000)) 'm' num2str(abs(peak_window(2)*1000)) 'ms'];
    
    % load channels with max- evoked responses
    load(['../data/peak/s' num2str(ns) '.max10chan.p50p200ms.postonset.mat']);
    
    % select peak-window , clera baseline
    cfg                                     = [];
    cfg.channel                             = max_chan;
    cfg.latency                             = peak_window;
    freq_peak                               = ft_selectdata(cfg,freq_comb);
    
    % round to make the 'find' job easier
    freq_peak.freq                          = round(freq_peak.freq);
    
    % look for a peak in the alpha range
    cfg                                     = [];
    cfg.method                              = 'maxabs' ;
    cfg.foi                                 = [7 14];
    apeak                                   = alpha_peak(cfg,freq_peak);
    apeak                                   = apeak(1);
    
    % look for a peak in the beta range
    cfg                                     = [];
    cfg.method                              = 'linear' ;
    cfg.foi                                 = [15 30];
    bpeak                                   = alpha_peak(cfg,freq_peak);
    bpeak                                   = bpeak(1);
    
    fprintf('\n\npeak found at %2d & %2d\n\n',apeak,bpeak);
    
    % save output
    fname_out                               = ['../data/peak/sub' num2str(ns) '.alphabetapeak.' peak_name '.mat'];
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'apeak','bpeak');
    
    keep ns
    
end