clear ; clc; close all;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nsess = 1
        
        fname                       = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %try getting peaks only on 0-back data
        find_zback                  = find(data.trialinfo(:,1) == 4);
        
        if isempty(find_zback)
            
            error('no trials found!');
            
        else
            
            cfg                     = [];
            cfg.trials              = find_zback;
            data_no_preproc       	= ft_selectdata(cfg,data); clear data;
            data_no_preproc         = megrepair(data_no_preproc);
            
            % - - low pass filtering
            cfg                  	= [];
            cfg.demean            	= 'yes';
            cfg.baselinewindow    	= [-0.1 0];
            cfg.lpfilter           	= 'yes';
            cfg.lpfreq           	= 20;
            data_preproc           	= ft_preprocessing(cfg,data_no_preproc);
            
            avg                    	= ft_timelockanalysis([], data_preproc);
            avg_comb             	= ft_combineplanar([],avg);
            avg_comb             	= rmfield(avg_comb,'cfg'); clc;
            
            avg_carr{nsess}      	= avg_comb; clear avg_comb;
            data_carr{nsess}      	= data_no_preproc; clear data_rep_nopreproc data_rep_preproc;
            
        end
    end
    
    % append 2 sessions if u used them both
    if length(avg_carr) > 1
        data                      	= ft_appenddata([],data_carr{:}); clear data_carr;
        avg                       	= ft_timelockgrandaverage([],avg_carr{:}); clear avg_carr;
    else
        data                        = data_carr{1};
        avg                         = avg_carr{1};
    end
    
    max_chan_window               	= [0.05 0.2];
    peak_window                     = [-0.998 0];
    
    right_hemi                      = {'MEG2232+2233','MEG2022+2023','MEG2242+2243', ...
        'MEG2442+2443','MEG2312+2313','MEG2032+2033','MEG2432+2433','MEG2322+2323', ...
        'MEG2342+2343','MEG2132+2133','MEG2522+2523','MEG2512+2513', ...
        'MEG2332+2333','MEG2122+2123','MEG2532+2533','MEG2542+2543'};
    
    left_hemi                       = {'MEG1842+1843','MEG1832+1833',  'MEG1912+1913','MEG1632+1633', ...
        'MEG1922+1923','MEG1942+1943','MEG1642+1643','MEG1932+1933','MEG1732+1733','MEG1722+1723', ...
        'MEG1742+1743','MEG1712+1713','MEG2012+2013','MEG2042+2043','MEG2142+2143','MEG2112+2113'};
    
    max_left                        = func_nback_findmax(avg,left_hemi,max_chan_window,10);
    max_right                       = func_nback_findmax(avg,right_hemi,max_chan_window,10);
    
    max_chan                        = [max_left;max_right];
    
    cfg                             = [];
    cfg.toilim                      = peak_window;
    data_slct                       = ft_redefinetrial(cfg,data);
    
    clear data avg;
    
    cfg                             = [] ;
    cfg.output                      = 'pow';
    cfg.method                      = 'mtmfft';
    cfg.keeptrials                  = 'no';
    cfg.pad                         = 'maxperlen';
    cfg.taper                       = 'hanning';
    cfg.foi                         = 1:1:40;
    cfg.tapsmofrq                   = 0;
    freq                            = ft_freqanalysis(cfg,data_slct);
    freq                            = rmfield(freq,'cfg');
    freq_comb                       = ft_combineplanar([],freq); clear freq;
    freq_comb                       = rmfield(freq_comb,'cfg');

    % select peak-window , clear baseline
    cfg                          	= [];
    cfg.channel                   	= max_chan;
    freq_peak                    	= ft_selectdata(cfg,freq_comb);
    
    freq_peak                       = rmfield(freq_peak,'cfg');
    
    % look for a peak in the alpha
    cfg                           	= [];
    cfg.method                      = 'maxabs' ;
    cfg.foi                         = [7 15];
    apeak                        	= alpha_peak(cfg,freq_peak);
    apeak                        	= apeak(1);
    
    % round to make the 'find' job easier
    freq_peak.freq              	= round(freq_peak.freq);
    
    % look for a peak in the beta range
    [bpeak,orig_nan]             	= h_findbetapeak(freq_peak,[15 30]);
    
    dir_data                        = '~/Dropbox/project_me/data/nback/peak/';
    fname_out                       = [dir_data 'sub' num2str(nsuj) '.alphabeta.peak.package.0back.equalhemi.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'apeak','bpeak','max_chan','max_chan_window','peak_window','orig_nan');
    
    dir_data                        = '~/Dropbox/project_me/data/nback/fft/';
    fname_out                       = [dir_data 'sub' num2str(nsuj) '.alphabeta.peak.fft.0back.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'freq_comb');
    
    keep nsuj
    
end