function bil_alpha_mtm_compute(subjectName)

if isunix
    subject_folder      = ['/project/3015079.01/data/' subjectName '/'];
else
    subject_folder      = ['P:/3015079.01/data/' subjectName '/'];
end

chk                     = dir([subject_folder 'tf/*firstcuelock.5t20Hz.1HzStep.KeepTrials.comb.mat']);

if isempty(chk)
    
    fname               = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    orig_name           = 'firstCueLock';
    
    % IMPORTANT!! -> do we want to exclude blocks with perfoamces either at chance
    % or celing
    % data_axial         	= h_excludebehav(dataPostICA_clean,13,16); clear dataPostICA_clean;
    
    data_axial         	= dataPostICA_clean;
    data_planar         = h_ax2plan(data_axial);
    
    cfg                 = [] ;
    cfg.output          = 'pow';
    cfg.method          = 'mtmconvol';
    cfg.keeptrials      = 'yes';
    cfg.pad             = 'maxperlen';
    
    cfg.foi             = 5:1:20;
    cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
    cfg.toi             = -1:0.05:7;
    
    cfg.taper           = 'hanning';
    cfg.tapsmofrq    	= 0.1 *cfg.foi;
    
    ext_freq            = h_freqparam2name(cfg);
    
    freq_planar         = ft_freqanalysis(cfg,data_planar);
    
    cfg                 = [];
    cfg.method          = 'sum';
    freq_comb           = ft_combineplanar(cfg,freq_planar);
    
    freq_comb           = rmfield(freq_comb,'cfg');
    
    dir_data            = [subject_folder 'tf/'];
    mkdir(dir_data);
    
    nm_prt              = strsplit(orig_name,'_');
    
    ext_name            = [lower(nm_prt{1}) '.' ext_freq '.comb'];
    fname               = [dir_data subjectName '.' ext_name '.mat'];
    fprintf('\nSaving %s\n',fname);
    save(fname,'freq_comb','-v7.3');
    
    fprintf('\ndone\n\n');
    
end