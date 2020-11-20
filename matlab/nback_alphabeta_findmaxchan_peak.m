clear ; clc; close all;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nsess = 1:2
        
        fname                       = ['K:/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        cfg                         = [];
        cfg.demean                  = 'yes';
        cfg.baselinewindow          = [-0.1 0];
        data                        = ft_preprocessing(cfg,data);
        
        data                        = rmfield(data,'cfg');
        data_repair                 = megrepair(data); clear data;
        
        avg                         = ft_timelockanalysis([], data_repair);
        avg_comb                    = ft_combineplanar([],avg);
        avg_comb                    = rmfield(avg_comb,'cfg'); clc;
        
        avg_carr{nsess}           	= avg_comb; clear avg_comb;
        data_carr{nsess}            = data_repair; clear data repair;
        
    end
    
    data                            = ft_appenddata([],data_carr{:}); clear data_carr;
    avg                             = ft_timelockgrandaverage([],avg_carr{:}); clear avg_carr;
    
    max_chan_window               	= [0.05 0.2];
    peak_window                     = [-1 0];
    
    cfg                             = [];
    cfg.latency                     = max_chan_window;
    cfg.avgovertime                 = 'yes';
    data_avg                        = ft_selectdata(cfg,avg); clear avg;
    
    vctr                            = [[1:length(data_avg.avg)]' data_avg.avg];
    vctr_sort                       = sortrows(vctr,2,'descend'); % sort from high to low
    
    lmt                             = 20; % number of channels to take
    max_chan                        = data_avg.label(vctr_sort(1:lmt,1));
    
    cfg                             = [];
    cfg.toilim                      = peak_window;
    data_slct                       = ft_redefinetrial(cfg,data); clear data;
    
    cfg                             = [] ;
    cfg.output                      = 'pow';
    cfg.method                      = 'mtmfft';
    cfg.keeptrials                  = 'no';
    cfg.pad                         = 'maxperlen';
    cfg.taper                       = 'hanning';
    cfg.foi                         = 1:1:30;
    cfg.tapsmofrq                   = 0.1 *cfg.foi;
    
    freq                            = ft_freqanalysis(cfg,data_slct);
    freq                            = rmfield(freq,'cfg');
    freq_comb                       = ft_combineplanar([],freq); clear freq;
    
    % select peak-window , clera baseline
    cfg                          	= [];
    cfg.channel                   	= max_chan;
    freq_peak                    	= ft_selectdata(cfg,freq_comb);
    
    % look for a peak in the alpha & beta range
    cfg                           	= [];
    cfg.method                      = 'maxabs' ;
    cfg.foi                         = [7 14];
    apeak                        	= alpha_peak(cfg,freq_peak);
    apeak                        	= apeak(1);
    
    % round to make the 'find' job easier
    freq_peak.freq              	= round(freq_peak.freq);
    
    % look for a peak in the beta range
    cfg                           	= [];
    cfg.method                      = 'linear' ;
    cfg.foi                       	= [15 30];
    bpeak                        	= alpha_peak(cfg,freq_peak);
    bpeak                        	= bpeak(1);
    
    fname_out                       = ['J:\temp\nback\data\peak\sub' num2str(nsuj) '.alphabeta.peak.package.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'apeak','bpeak','max_chan','max_chan_window','peak_window');
    
    keep nsuj
    
end