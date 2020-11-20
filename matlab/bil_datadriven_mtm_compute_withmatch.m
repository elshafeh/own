clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    subject_folder              = ['P:/3015079.01/data/' subjectName '/'];
    fname                       = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    data_axial                  = dataPostICA_clean;
    data_planar                 = h_ax2plan(data_axial);
    
    trialinfo                   = data_axial.trialinfo;
    trialinfo                   = trialinfo(trialinfo(:,16) == 1,6)+1; % col 1match or not
    trialinfo                   = [trialinfo [1:length(trialinfo)]']; % col 2 in index 
    
    list_match                  = {'nomatch','match'};
    
    for nmatch = 1:2
        
        cfg                     = [];
        cfg.output              = 'pow';
        cfg.method              = 'mtmconvol';
        cfg.keeptrials          = 'no';
        cfg.pad                 = 'maxperlen';
        cfg.foi                 = [1:1:40 42:2:100];
        cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.5;
        cfg.toi                 = -1:0.05:7;
        cfg.taper               = 'hanning';
        cfg.tapsmofrq           = 0.1 *cfg.foi;
        cfg.trials              = trialinfo(trialinfo(:,1) == nmatch,2);
        
        if ~isempty(cfg.trials)
            ext_freq            = h_freqparam2name(cfg);
            freq_planar         = ft_freqanalysis(cfg,data_planar);
            
            cfg = []; cfg.method = 'sum';
            freq_comb           = ft_combineplanar(cfg,freq_planar);
            freq_comb           = rmfield(freq_comb,'cfg');
            
            ext_fname           = [list_match{nmatch}];
            
            dir_data            = 'I:/bil/tf/';
            fname               = [dir_data subjectName '.cuelock.correct.' ext_freq '.'  ext_fname '.mat'];
            fprintf('\nSaving %s\n',fname);
            save(fname,'freq_comb','-v7.3'); clear freq_comb;
        end
    end
end