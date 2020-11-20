clear ;

for ns = [1:33 35:36 38:44 46:51]
    
    for i = 1:2
        
        fname                                   = ['../data/tf/sub' num2str(ns) '.sess' num2str(i) '.allback.1t30Hz.1HzStep.AvgTrials.stk.exl.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp{i}                                  = freq_comb; clear freq_comb;
        
    end
    
    %     concatenate all data from all conditions
    freq_comb                               = ft_freqgrandaverage([],tmp{:});
    
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
    
    % look for a peak in the alpha & beta range
    cfg                                     = [];
    cfg.method                              = 'linear' ;
    cfg.foi                                 = [15 30];
    bpeak                                   = alpha_peak(cfg,freq_peak);
    
    bpeak                                   = bpeak(1);
    
    %     if isnan(bpeak)
    %         error('NaN!');
    %     else
    fprintf('\n\npeak found at %d\n\n',bpeak);
    %     end
    
    subjectName                             = ['s' num2str(ns)];
    
    % save output
    fname_out                               = ['../data/peak/' subjectName '.betapeak.' peak_name '.mat'];
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'bpeak');
    
    keep ns
    
end