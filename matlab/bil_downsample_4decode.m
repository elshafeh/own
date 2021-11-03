clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    subject_folder                  = [project_dir 'data/' subjectName '/preproc/'];
    
    fname                           = [subject_folder subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    t1                              = 0.2;
    t2                              = 3.1;
    
    time_win                        = [t1 t2];
    
    %     cfg                             = [];
    %     cfg.latency                     = [-t1 t2];
    %     data_axial{1}                   = ft_selectdata(cfg,dataPostICA_clean);
    %     data_axial{2}                   = bil_changelock_onlysecondcue(subjectName,time_win,dataPostICA_clean); clear dataPostICA_clean;
    
    data_axial{1}                   = bil_changelock_1stgab(subjectName,time_win,dataPostICA_clean);
    %     data_axial{2}                   = bil_changelock_2ndgab(subjectName,time_win,dataPostICA_clean); clear dataPostICA_clean;
    
    list_lock                       = {'1stgab'}; % '2ndgab'}; % {'1stcue' '2ndcue'};
    list_name                       = 'broadband';
    
    for nlock = 1:length(data_axial)
        
        % downsample 
        cfg                         = [];
        cfg.resamplefs           	= 70;
        cfg.detrend             	= 'no';
        cfg.demean                	= 'no';
        data                      	= ft_resampledata(cfg, data_axial{nlock});
        data                        = rmfield(data,'cfg');
        
        index                       = data.trialinfo;
        
        fname_out                   = [subject_folder subjectName '.' list_lock{nlock} '.lock.' list_name '.centered.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'data','-v7.3');toc;
        
        fname_out                   = [subject_folder subjectName '.' list_lock{nlock} '.lock.' list_name '.centered.trialinfo.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'index');toc;
        
        clear data index
        
    end
    
    clear data_axial;
    
end