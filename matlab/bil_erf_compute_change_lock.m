clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    subject_folder                          = ['P:/3015079.01/data/' subjectName '/'];
    fname                                   = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % - - low pass filtering
    cfg                                     = [];
    cfg.demean                              = 'yes';
    cfg.baselinewindow                      = [-0.1 0];
    cfg.lpfilter                            = 'yes';
    cfg.lpfreq                              = 20;
    data_preproc                            = ft_preprocessing(cfg,dataPostICA_clean); clear dataPostICA_clean;
    
    cfg                                     = [];
    cfg.latency                             = [-0.2 2];
    data_axial{1}                           = ft_selectdata(cfg,data_preproc);
    data_axial{2}                           = bil_changelock_onlysecondcue(subjectName,[0.2 2],data_preproc);
    data_axial{2}.trialinfo                 = data_axial{2}.trialinfo(:,1:size(data_axial{1}.trialinfo,2));
    
    data_axial{3}                           = bil_changelock_onlyprobe(subjectName,[0.2 2],data_preproc);
    data_axial{4}                           = bil_changelock_onlytarget(subjectName,[0.2 2],data_preproc);
    
    data_axial{5}                           = ft_appenddata([],data_axial{1},data_axial{2}); % concatenate cues
    data_axial{6}                           = ft_appenddata([],data_axial{3},data_axial{4}); % concatenate gabors
    
    list_lock                               = {'1stcue.lock' '2ndcue.lock' '1stgab.lock' '2ndgab.lock' 'allcue.lock' 'allgab.lock'};
    
    for nlock = 1:length(list_lock)
        
        % - - computing average
        cfg                                 = [];
        cfg.trials                          = find(data_axial{nlock}.trialinfo(:,16) == 1);
        avg                                 = ft_timelockanalysis([], data_axial{nlock});
        
        % - - combine planar
        cfg                                 = [];
        cfg.feedback                        = 'yes';
        cfg.method                          = 'template';
        cfg.neighbours                      = ft_prepare_neighbours(cfg, avg); close all;
        cfg.planarmethod                    = 'sincos';
        avg_planar                          = ft_megplanar(cfg, avg);
        avg_comb                            = ft_combineplanar([],avg_planar);
        
        avg_comb                            = rmfield(avg_comb,'cfg');
        avg                                 = rmfield(avg,'cfg');
        
        fname                               = ['J:\temp\bil\erf\' subjectName '.' list_lock{nlock} '.correct.erfComb.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'avg_comb','-v7.3');
        
        fprintf('\ndone\n\n');
        
    end
end