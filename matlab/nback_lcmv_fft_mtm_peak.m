clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

for n_suj = 1:length(suj_list)
    for n_ses = 1:2
        
        fname                   = ['../../data/source/virtual/0.5cm/sub' num2str(suj_list(n_suj)) '.session' num2str(n_ses) '.brain0.5.broadband.dwn80.virt.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % add session to end of trial_info
        data.trialinfo          = [data.trialinfo repmat(n_ses,length(data.trialinfo),1)];
        
        data_car{n_ses}         = data; clear data;
        
    end
    
    data                        = ft_appenddata([],data_car{:}); clear data_car;
    
    %     % remove mean
    %     cfg                         = [];
    %     cfg.demean                  = 'yes';
    %     cfg.baselinewindow          = 'all';
    %     data                        = ft_preprocessing(cfg,data);
    
    % define prestimulus window
    cfg                         = [];
    cfg.latency                 = [-1 0];
    prestim_data                = ft_selectdata(cfg, data);
    
    clear secondreject_postica cfg ;
    
    % fast fourier transform
    cfg                         = [] ;
    cfg.output                  = 'pow';
    cfg.method                  = 'mtmfft';
    cfg.keeptrials              = 'yes';
    cfg.taper                   = 'hanning';
    cfg.pad                     = 3;              % padding zeros at the beginning and end of each trial
    cfg.foi                     = 5:1/cfg.pad:30;
    cfg.tapsmofrq               = 1;%0.2 *cfg.foi;
    cfg.keeptrials              = 'no';
    
    freq                        = ft_freqanalysis(cfg,prestim_data);
    allpeaks                    = [];
    
    for nchan = 1:length(freq.label)
        
        tmp                     = freq;
        tmp.powspctrm           = tmp.powspctrm(nchan,:);
        tmp.label               = tmp.label(nchan);
        
        cfg                     = [];
        cfg.method              = 'maxabs' ;
        cfg.foi                 = [7 14];
        apeak                   = alpha_peak(cfg,tmp);
        apeak                   = apeak(1);
        
        % look for a peak in the beta range
        cfg                     = [];
        cfg.method              = 'linear' ;
        cfg.foi                 = [15 30];
        bpeak                   = alpha_peak(cfg,tmp);
        bpeak                   = bpeak(1);
        
        allpeaks(nchan,:)       = [apeak bpeak]; clear apeak tmp bpeak;
        
    end
    
    %     fname                       = ['../../data/peak/sub' num2str(suj_list(n_suj)) '.demean.all.brainbroadband.m1p0s.alphabetapeak.mat'];
    %     fprintf('Saving %s\n',fname);
    %     save(fname,'allpeaks','-v7.3');
    
    time_width                  = 0.03;
    freq_width                  = 1;
    
    time_list                   = -1.5:time_width:6;
    freq_list                   = 6:(1/3):32;
    
    cfg                         = [] ;
    cfg.output                  = 'pow';
    cfg.method                  = 'mtmconvol';
    cfg.keeptrials              = 'yes';
    cfg.taper                   = 'hanning';
    cfg.pad                     = 'nextpow2';
    cfg.toi                     = time_list;
    cfg.foi                     = freq_list;
    cfg.t_ftimwin               = ones(length(cfg.foi),1).*0.5;
    cfg.tapsmofrq               = 1;%0.2 *cfg.foi;
    freq                        = ft_freqanalysis(cfg,data);
    freq                        = rmfield(freq,'cfg');
    
    cfg                         = [];
    cfg.baseline                = [-0.4 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    mean_peaks                  = nanmean(allpeaks,1);
    
    orig_data                   = data; clear data;
    orig_data                   = rmfield(orig_data,'cfg');
    
    for nfreq = 2
        
        data                    = orig_data;
        data.trial              = {};
        data.time               = {};
        data.fsample            = round(1/0.03,2); 
        
        for ntrial = 1:length(freq.trialinfo)
            
            pow                 = [];
            
            for nchan = 1:length(freq.label)
                
                apeak         	= allpeaks(nchan,nfreq);
                
                if isnan(apeak)
                    apeak     	= mean_peaks(nfreq);
                end
                
                bnwidth        	= [1 2];
                
                f1             	= abs(freq.freq - (apeak-bnwidth(nfreq)));
                f2            	= abs(freq.freq - (apeak+bnwidth(nfreq)));
                
                f1             	= find(f1 == min(f1));
                f2             	= find(f2 == min(f2));
                
                pow(nchan,:)  	= [nanmean(squeeze(freq.powspctrm(ntrial,nchan,f1:f2,:)),1)]';
                
                if apeak < 15
                    list_name{nfreq}    = ['alpha' num2str(bnwidth(nfreq)) 'Hz'];
                else
                    list_name{nfreq}    = ['beta' num2str(bnwidth(nfreq)) 'Hz'];
                end
                
            end
            
            data.trial{ntrial}  = pow; clear pow;
            data.time{ntrial}   = freq.time;
            
        end
        
        fname_out               = ['../../data/tf/sub' num2str(suj_list(n_suj)) '.brainbroadband.mtmavg.' list_name{nfreq} '.bslcorrected.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'data','-v7.3');toc
        clear data;
        
    end
    
    keep n_suj suj_list
    
end

