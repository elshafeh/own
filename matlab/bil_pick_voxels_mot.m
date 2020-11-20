clear;

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
    subject_folder                  = ['P:/3015079.01/data/' subjectName '/'];
    
    fname                           = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    data                            = bil_changelock_onlyresp(subjectName,[1 0.5],dataPostICA_clean); clear dataPostICA_clean;
        
    % -- low pass filtering
    cfg                         	= [];
    cfg.demean                      = 'no';
    cfg.lpfilter                	= 'yes';
    cfg.lpfreq                   	= 20;
    data_preproc                  	= ft_preprocessing(cfg,data);

    % -- load in headmodel
    fname                           = ['I:/bil/head/' subjectName '.volgridLead.0.5cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
 	% -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                         	= [];
    cfg.channel                     = data_preproc.label; %max_chan; %
    lead_select                    	= ft_selectdata(cfg,leadfield);
    data_select                   	= ft_selectdata(cfg,data_preproc);
    
    % create common spatial filter
    cfg_f                           = [];
    cfg_f.covariance_window         = [-0.6 0.4]; % [baseline_window(1) max_lat+0.05];
    cfg_f.leadfield                 = lead_select;
    cfg_f.vol                       = vol;
    spatialfilter                   = h_create_lcmv_common_filter(cfg_f,data_select);
    
    cfg_s                           = [];
    cfg_s.leadfield                 = lead_select;
    cfg_s.vol                       = vol;
    cfg_s.spatialfilter             = spatialfilter;
    
    % -- compute lcmv source for the baseline
    cfg_s.time_of_interest          = [-0.6 -0.1];
    [source_bsl,~]                  = h_lcmv_separate(cfg_s,data_select);
    
    % -- compute lcmv source for the baseline
    cfg_s.time_of_interest          = [-0.1 0.4]; % [max_lat-0.05 max_lat+0.05];
    [source_act,~]                  = h_lcmv_separate(cfg_s,data_select);
    
    load('../data/stock/template_grid_0.5cm.mat');
    
    %-- prepare source for plotting
    source                      	= [];
    source.pos                   	= template_grid.pos;
    source.dim                  	= template_grid.dim;
    source.pow                    	= (source_act - source_bsl) ./ source_bsl;
    source.pow                      = abs(source.pow);
    
    cfg                          	= [];
    cfg.method                  	= 'surface';
    cfg.funparameter              	= 'pow';
    cfg.maskparameter           	= cfg.funparameter;
    cfg.funcolormap              	= brewermap(256,'Reds');
    cfg.projmethod               	= 'nearest';
    cfg.camlight                   	= 'no';
    cfg.surfinflated               	= 'surface_inflated_both_caret.mat';
    cfg.colorbar                    = 'no';
    cfg.funcolorlim                	= 'zeromax';
    cfg.funcolormap               	= brewermap(256,'Reds');
    ft_sourceplot(cfg, source);
    title(subjectName);
    
    nb_max_vox                      = 5;
    vctr                            = source.pow;
    max_vox_index                   = [];
    
    for i = 1:nb_max_vox
        fnd_max                     = find(vctr == nanmax(vctr));
        max_vox_index            	= [max_vox_index;fnd_max];
        vctr(fnd_max)               = NaN; clear fnd_max;
    end
    
    source.pow(:)                   = NaN;
    source.pow(max_vox_index)       = 1;
    
    cfg.funcolorlim                	= [0 1];
    ft_sourceplot(cfg, source);
    title(subjectName);
    
end