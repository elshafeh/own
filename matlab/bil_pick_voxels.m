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
    
    data_axial{1}                   = bil_changelock_1stgab(subjectName,[0.5 1],dataPostICA_clean);
    data_axial{2}                   = bil_changelock_2ndgab(subjectName,[0.5 1],dataPostICA_clean); clear dataPostICA_clean;
    
    data                            = ft_appenddata([],data_axial{:}); clear data_axial
    
    baseline_window                 = [-0.1 0];
    
    % -- low pass filtering
    cfg                         	= [];
    cfg.demean                      = 'yes';
    cfg.baselinewindow          	= baseline_window;
    cfg.lpfilter                	= 'yes';
    cfg.lpfreq                   	= 20;
    data_preproc                  	= ft_preprocessing(cfg,data);
    
    % -- computing average
    avg                           	= ft_timelockanalysis([], data_preproc);
    
    % -- combine planar
    cfg                           	= [];
    cfg.feedback                  	= 'yes';
    cfg.method                   	= 'template';
    cfg.neighbours                	= ft_prepare_neighbours(cfg, avg); close all;
    cfg.planarmethod               	= 'sincos';
    avg_planar                     	= ft_megplanar(cfg, avg);
    avg_comb                     	= ft_combineplanar([],avg_planar);
    
    cfg                             = [];
    cfg.baseline                    = baseline_window;
    avg_bsl                         = ft_timelockbaseline(cfg,avg_comb);
    
    % -- find channels with maximum response
    [max_chan]                      = h_maxchan(avg_bsl,[0 0.5],{'M*O*'},20);
    % -- find peak latency
    [max_lat]                       = h_maxlatency(avg_bsl,[0 0.5],max_chan);
    
    cfg                             =[];
    cfg.channel                     = max_chan;
    ft_singleplotER(cfg,avg_bsl);
    vline(max_lat,'--k');title('');

    % -- load in headmodel
    fname                           = ['I:/bil/head/' subjectName '.volgridLead.0.5cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
 	% -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                         	= [];
    cfg.channel                     = data_preproc.label;
    leadfield                   	= ft_selectdata(cfg,leadfield);
    
    % create common spatial filter
    cfg_f                           = [];
    cfg_f.covariance_window         = [-0.5 1];
    cfg_f.leadfield                 = leadfield;
    cfg_f.vol                       = vol;
    spatialfilter                   = h_create_lcmv_common_filter(cfg_f,data_preproc);
    
    cfg_s                           = [];
    cfg_s.leadfield                 = leadfield;
    cfg_s.vol                       = vol;
    cfg_s.spatialfilter             = spatialfilter;
    
    % -- compute lcmv source for the baseline
    cfg_s.time_of_interest          = baseline_window;
    [source_bsl,~]                  = h_lcmv_separate(cfg_s,data_preproc);
    
    % -- compute lcmv source for the baseline
    cfg_s.time_of_interest          = [max_lat-0.05 max_lat+0.05];
    [source_act,~]                  = h_lcmv_separate(cfg_s,data_preproc);
    
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
    cfg.funcolormap              	= brewermap(256,'Reds'); % brewermap(256,'Reds');
    cfg.projmethod               	= 'nearest';
    cfg.camlight                   	= 'no';
    cfg.surfinflated               	= 'surface_inflated_both_caret.mat';
    cfg.colorbar                    = 'no';
    cfg.funcolorlim                	= 'maxabs';
    cfg.funcolormap               	= brewermap(256,'Reds');
    ft_sourceplot(cfg, source);
    
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
    
end