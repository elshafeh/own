clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

suj_list                                        = dir([project_dir 'data/sub*/preproc/*finalrej.mat']);

for ns = 1:length(suj_list)
    
    subjectName                              	= suj_list(ns).name(1:6);
    
    fname                                       = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    data_axial                              	= dataPostICA_clean; clear dataPostICA_clean;
    
    data_planar                                 = h_ax2plan(data_axial);
    
    time_win1                                   = -0.1;
    time_win2                                   = 6.5;
    
    frq1                                        = 1;
    frq2                                        = 10;
    
    cfg                                         = [];
    cfg.output                                  = 'fourier';
    cfg.method                                  = 'mtmconvol';
    cfg.taper                                   = 'hanning';
    cfg.foi                                     = frq1:1:frq2;
    cfg.toi                                     = time_win1:0.05:time_win2;
    cfg.t_ftimwin                               = ones(length(cfg.foi),1).*0.5;   % 5 cycles
    cfg.keeptrials                              = 'yes';
    cfg.pad                                     = 10;
    
    freq_planar                                 = ft_freqanalysis(cfg,data_planar);
    cfg                                         = []; cfg.method = 'svd';
    freq_comb                                   = ft_combineplanar(cfg,freq_planar);
    freq_comb                                   = rmfield(freq_comb,'cfg');
    
    phase_lock                                  = bil_itc_sortRT_compute(freq_comb,5);
    
    fname                                       = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
    fprintf('\nSaving %s\n',fname);
    tic;save(fname,'phase_lock','-v7.3');toc; clear phase_lock
    
    
end
