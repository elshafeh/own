clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
else
    project_dir                     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    fname                           = ['I:/hesham/bil/head/' subjectName '.volgridLead.1cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                           = [project_dir 'data/' subjectName '/preproc/' subjectName '.firstgab.lock.dwnsample70Hz.mat'];
    fprintf('loading %s\n',fname);
    load(fname); data_gab{1}        = data; clear data;
    
    fname                           = [project_dir 'data/' subjectName '/preproc/' subjectName '.secondgab.lock.dwnsample70Hz.mat'];
    fprintf('loading %s\n',fname);
    load(fname); data_gab{2}        = data; clear data;
    
    data                            = ft_appenddata([],data_gab{:}); clear data_gab;
    
    cfg                            	= [];
    cfg.channel                   	= data.label;
    leadfield                    	= ft_selectdata(cfg,leadfield);

    cfg_f                           = [];
    cfg_f.covariance_window         = [-0.1 0.2];
    cfg_f.leadfield                 = leadfield;
    cfg_f.vol                       = vol;
    spatialfilter                   = h_create_lcmv_common_filter(cfg_f,data);
    
    list_time                       = [-0.1 0; 0.1 0.2]; % windows of interest
    
    for ntime = 1:size(list_time,1)
        
        cfg_s                       = [];
        cfg_s.leadfield             = leadfield;
        cfg_s.vol                   = vol;
        cfg_s.spatialfilter         = spatialfilter;
        cfg_s.time_of_interest      = list_time(ntime,:);
        [source,source_name]        = h_lcmv_separate(cfg_s,data);

        fname_out                   = ['I:/bil/source/' subjectName '.gratinglock.' source_name '.lcmvsource.1cmWithNas.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'source','-v7.3');
        
    end
    
end