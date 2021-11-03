clear ; clc;

for ns = 1:length(suj_list)
    
    subjectName                               	= suj_list(ns).name(1:6);
    
    % load in data
    fname                                    	= [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % convert axial to planar
    data_axial                                 	= dataPostICA_clean; clear dataPostICA_clean;
    data_planar                                	= h_ax2plan(data_axial);
    
    time_win1                                   = -0.1;
    time_win2                                   = 6.5;
    
    freq1                                       = 1;
    freq2                                       = 30;
    
    cfg                                         = [];
    cfg.output                                  = 'fourier';
    cfg.method                                  = 'mtmconvol';
    cfg.taper                                   = 'hanning';
    cfg.foi                                     = freq1:1:freq2;
    cfg.toi                                     = time_win1:0.05:time_win2;
    cfg.t_ftimwin                               = ones(length(cfg.foi),1).*0.5;   % 5 cycles
    
    % u can either vchoose your trials here OR with the
    % mbon_PhaseLockingFactor function but always keeptrials = ON;
    cfg.trials                              	= find(data_planar.trialinfo(:,16) == 1); % choose correct trials
    
    cfg.keeptrials                              = 'yes';
    cfg.pad                                     = 10;
    freq_planar                                 = ft_freqanalysis(cfg,data_planar);
    
    cfg                                         = []; cfg.method = 'svd';
    freq_comb                                   = ft_combineplanar(cfg,freq_planar);
    freq_comb                                   = rmfield(freq_comb,'cfg');
    
    
    cfg                                         = [];
    cfg.indexchan                               = 'all';
    cfg.index                                   = 'all';
    cfg.alpha                                   = 0.05;
    cfg.time                                    = [time_win1 time_win2];
    cfg.freq                                    = [freq1 freq2];
    
    % make sure that the output has values in it
    phase_lock                                  = mbon_PhaseLockingFactor(cfg,freq_comb);
    
    
end