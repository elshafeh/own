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
    
    orig_data                 	= ft_appenddata([],data_car{:}); clear data_car;
    
    time_width                  = 0.05;
    freq_width                  = 1;
    
    time_list                   = -1.5:time_width:6;
    freq_list                   = 5:freq_width:35;
    
    cfg                         = [] ;
    cfg.output                  = 'pow';
    cfg.method                  = 'mtmconvol';
    cfg.keeptrials              = 'yes';
    cfg.taper                   = 'hanning';
    cfg.pad                     = 'nextpow2';
    cfg.toi                     = time_list;
    cfg.foi                     = freq_list;
    cfg.t_ftimwin               = 5./cfg.foi;
    cfg.tapsmofrq               = 0.2 *cfg.foi;
    freq                        = ft_freqanalysis(cfg,orig_data);
    
    cfg                         = [];
    cfg.baseline                = [-0.4 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    for nf = 1:length(freq_list)
        
        data                    = orig_data;
        
        for xi = 1:length(data.trial)
            data.trial{xi}      = squeeze(freq.powspctrm(xi,:,nf,:));
            data.time{xi}       = freq.time;
        end
        
        fname_out               = ['/project/3015039.04/hesham_temp_data/mtm/sub' num2str(suj_list(n_suj)) '.broadband.bslcorr.' num2str(round(freq.freq(nf))) 'Hz.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'data');toc;
        
        clear data;clc;
        
    end
    
end