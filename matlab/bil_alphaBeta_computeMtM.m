clear ; close all;

suj_list                    = dir('../data/sub*/preproc/*finalrej.mat');

for ns = 1:length(suj_list)
    
    subjectName             = suj_list(ns).name(1:6);
    
    chk                     = dir(['../data/' subjectName '/tf/*firstcuelock.mtmconvolPOW.m1000p6000ms.30msStep.5t40Hz.1HzStep.KeepTrials.comb.mat']);
    
    if isempty(chk)
        
        fname               = [suj_list(ns).folder '/' suj_list(ns).name];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        orig_name           = 'firstCueLock';
        
        data_axial          = dataPostICA_clean; clear dataPostICA_clean;
        data_planar         = h_ax2plan(data_axial);
        
        cfg                 = [] ;
        cfg.output          = 'pow';
        cfg.method          = 'mtmconvol';
        cfg.keeptrials      = 'yes';
        cfg.pad             = 'nextpow2';
        cfg.taper           = 'hanning';
        
        cfg.foi             = 5:1:40;
        cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5; % 1./cfg.foi; % 
        cfg.tapsmofrq       = 0.2 *cfg.foi;
        
        cfg.toi             = -1:0.03:6;
        
        ext_freq            = h_freqparam2name(cfg);
        
        freq_planar         = ft_freqanalysis(cfg,data_planar);
        
        cfg                 = [];
        cfg.method          = 'sum';
        freq_comb           = ft_combineplanar(cfg,freq_planar);
        
        freq_comb           = rmfield(freq_comb,'cfg');
        
        dir_data            = ['../data/' subjectName '/tf/'];
        mkdir(dir_data);
        
        nm_prt              = strsplit(orig_name,'_');
        
        ext_name            = [lower(nm_prt{1}) '.' ext_freq '.comb'];
        fname               = [dir_data subjectName '.' ext_name '.mat'];
        fprintf('\nSaving %s\n',fname);
        save(fname,'freq_comb','-v7.3');
        
        fprintf('\ndone\n\n');
        
    end
    
end