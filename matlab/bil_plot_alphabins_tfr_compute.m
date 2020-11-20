clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    subject_folder          = ['P:/3015079.01/data/' subjectName '/'];
    fname                   = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    data_axial              = dataPostICA_clean;
    data_planar             = h_ax2plan(data_axial);
    
    title_win               = 'preCue1';
    fname                   = [subject_folder  '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.' ...
        'm1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.5Bins.1Hz.window.' title_win '.all.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nbin = 1:size(bin_summary.bins,2)
        
        cfg                 = [] ;
        cfg.output          = 'pow';
        cfg.method          = 'mtmconvol';
        cfg.keeptrials      = 'no';
        cfg.pad             = 'maxperlen';
        cfg.foi             = [1:1:40 42:2:60 65:5:100];
        cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
        cfg.toi             = -2:0.02:7;
        cfg.taper           = 'hanning';
        cfg.tapsmofrq    	= 0.1 *cfg.foi;
        cfg.trials          = bin_summary.bins(:,nbin);
        
        freq_planar         = ft_freqanalysis(cfg,data_planar);
        ext_freq            = h_freqparam2name(cfg);
        
        cfg = []; cfg.method = 'sum';
        freq_comb           = ft_combineplanar(cfg,freq_planar);
        freq_comb           = rmfield(freq_comb,'cfg');
        
        dir_data            = 'I:/hesham/bil/tf/';
        fname               = [dir_data subjectName '.cuelock.' ext_freq '.' title_win 'alphasorted.bin' num2str(nbin) '.mat'];
        fprintf('\nSaving %s\n',fname);
        save(fname,'freq_comb','-v7.3'); clear freq_comb;
        
    end
end