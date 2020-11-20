clear ;

for ns = [1:33 35:36 38:44 46:51]
    
    i                                       = 0 ;
    subjectName                             = ['sub' num2str(ns)];clc;
    
    % load data from all conditions
    check_name                              = dir(['/Volumes/heshamshung/nback/tf/' subjectName '.sess*.allback.1t20Hz*.stakcombined.mat']);
    
    for nf = 1:length(check_name)
        
        fname                               = [check_name(nf).folder filesep check_name(nf).name];
        fprintf('loading %s\n',fname);
        load(fname);
        
        tmp{nf}                             = freq_comb; clear freq_comb;
        
    end
    
    % avearge both sessions
    freq_comb                               = ft_freqgrandaverage([],tmp{:}); clear tmp;
    
    peak_window                             = [-0.5 0];
    peak_name                               = ['m' num2str(abs(peak_window(1)*1000)) 'm' num2str(abs(peak_window(2)*1000)) 'ms'];
    
    % load channels with max- evoked responses
    load(['/Volumes/heshamshung/nback/peak/s' num2str(ns) '.max10chan.p50p200ms.postonset.mat']);
    
    % select peak-window , clera baseline
    cfg                                     = [];
    cfg.channel                             = max_chan;
    cfg.latency                             = peak_window;
    freq_peak                               = ft_selectdata(cfg,freq_comb);
    
    % look for a peak in the alpha & beta range
    cfg                                     = [];
    cfg.method                              = 'maxabs' ;
    cfg.foi                                 = [7 14];
    apeak                                   = alpha_peak(cfg,freq_peak);
    apeak                                   = apeak(1);
    
    % save output
    fname_out                               = ['/Volumes/heshamshung/nback/peak/' subjectName '.alphapeak.' peak_name '.mat'];
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'apeak');
    
    keep ns
    
end