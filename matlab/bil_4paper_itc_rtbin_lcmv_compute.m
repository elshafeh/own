clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
else
    project_dir                     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    fname                           = ['I:/bil/head/' subjectName '.volgridLead.0.5cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                           = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);

    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                         	= [];
    cfg.channel                     = dataPostICA_clean.label;
    leadfield                   	= ft_selectdata(cfg,leadfield);
    
    % create common spatial filter 
    cfg_f                           = [];
    cfg_f.covariance_window         = [-0.5 5.5];
    cfg_f.leadfield                 = leadfield;
    cfg_f.vol                       = vol;
    spatialfilter                   = h_create_lcmv_common_filter(cfg_f,dataPostICA_clean);
    
    % make sure of what file you load!
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % deinfe time windows of interest
    list_time                       = [-0.6 -0.2;3.7 5];
    
    % define indices
    for nbin = 1:5
        
        cfg                         = [];
        cfg.trials                  = phase_lock{nbin}.index;
        data_slct                   = ft_selectdata(cfg,dataPostICA_clean);
        
        for ntime = 1:size(list_time,1)
            
            cfg_s                   = [];
            cfg_s.leadfield       	= leadfield;
            cfg_s.vol             	= vol;
            cfg_s.spatialfilter   	= spatialfilter;
            cfg_s.time_of_interest 	= list_time(ntime,:);
            [source,source_name]  	= h_lcmv_separate(cfg_s,data_slct);
            
            fname_out           	= [project_dir 'data/' subjectName '/source/' subjectName '.cuelock.rtBin' num2str(nbin) '.' source_name '.lcmvsource.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'source','-v7.3');
            
        end
        
        clear data_slct
        
    end
end