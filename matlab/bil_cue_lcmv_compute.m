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
    
    % -- sub-select correct trials
    cfg                           	= [];
    cfg.trials                    	= find(dataPostICA_clean.trialinfo(:,16) == 1);
    dataPostICA_clean            	= ft_selectdata(cfg,dataPostICA_clean);
    
    % create common spatial filter 
    cfg_f                           = [];
    cfg_f.covariance_window         = [-0.5 5.5];
    cfg_f.leadfield                 = leadfield;
    cfg_f.vol                       = vol;
    spatialfilter                   = h_create_lcmv_common_filter(cfg_f,dataPostICA_clean);

    list_time                       = [3.7 5];
    
    %     list_time(:,1)                  = [-0.2:0.1:1.4];
    %     list_time(:,2)                  = list_time(:,1) + 0.1;
    
    for ntime = 1:size(list_time,1)
        
        cfg_s                       = [];
        cfg_s.leadfield             = leadfield;
        cfg_s.vol                   = vol;
        cfg_s.spatialfilter         = spatialfilter;
        cfg_s.time_of_interest      = list_time(ntime,:);
        [source,source_name]        = h_lcmv_separate(cfg_s,dataPostICA_clean);

        fname_out                   = [project_dir 'data/' subjectName '/source/' subjectName '.1stcue.lock.' source_name '.lcmvsource.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'source','-v7.3');
        
    end
end