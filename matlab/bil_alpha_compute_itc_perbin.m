clear ; clc;

if isunix
    project_dir     = '/project/3015079.01/';
else
    project_dir     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                     = suj_list{nsuj};
    
    fname                                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.' ...
        'm1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.5Bins.1Hz.window.preCue1.all.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname                                           = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    data_planar                                     = h_ax2plan(dataPostICA_clean); clear dataPostICA_clean
    
    for nbin = 1:size(bin_summary.bins,2)
        
        time_win1                                   = -0.1;
        time_win2                                   = 6.5;
        
        f1                                          = 2;
        f2                                          = 7;
        
        cfg                                         = [];
        cfg.output                                  = 'fourier';
        cfg.method                                  = 'mtmconvol';
        cfg.taper                                   = 'hanning';
        cfg.trials                                  = bin_summary.bins(:,nbin);
        cfg.foi                                     = f1:1:f2;
        cfg.toi                                     = time_win1:0.05:time_win2;
        cfg.t_ftimwin                               = ones(length(cfg.foi),1).*0.5;   % 5 cycles
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
        cfg.freq                                    = [f1 f2];
        phase_lock                                  = mbon_PhaseLockingFactor(freq_comb, cfg);
        fname                                       = ['J:\temp\bil\tf\' subjectName '.cuelock.alphabin' num2str(nbin) '.itc.comb.mat'];
        fprintf('\nSaving %s\n',fname);
        tic;save(fname,'phase_lock','-v7.3');toc; clear phase_lock
        
    end
end