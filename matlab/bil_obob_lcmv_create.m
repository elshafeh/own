clear ; close all;

if isunix
    project_dir                         = '/project/3015079.01/';
    addpath('/home/mrphys/hesels/github/obob_ownft/');
else
    project_dir                         = 'P:/3015079.01/';
end

obob_init_ft;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    
    fname                               = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);data                 	= dataPostICA_clean; clear dataPostICA_clean
    
    fname                               = ['/project/3015039.06/bil/head/' subjectName '.volgridLead.obob.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);
    
    load('../data/stock/obob_parcellation_grid_5mm.mat');
    
    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                                 = [];
    cfg.channel                         = data.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    dwn_sample_freq                     = 70;
    
    % DownSample
    cfg                                 = [];
    cfg.resamplefs                      = dwn_sample_freq;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'no';
    data                                = ft_resampledata(cfg, data);

    cfg                                 = [];
    cfg.covariance                      = 'yes';
    cfg.covariancewindow                = [-1 6];
    avg                                 = ft_timelockanalysis(cfg,data);
    avg.grad                            = ft_convert_units(avg.grad,'m');
    
    cfg                                 = [];
    cfg.grid                            = leadfield;
    cfg.fixedori                        = 'yes';
    cfg.parcel                          = parcellation;
    cfg.parcel_avg                      = 'avg_filters';%'svd_sources';
    cfg.regfac                          = '5%';
    filter                              = obob_svs_compute_spat_filters(cfg,avg);
    
    cfg                                 = [];
    cfg.spatial_filter                  = filter;
    data_virt                           = obob_svs_beamtrials_lcmv(cfg,data); % <- virtual channel!!
        
    fname_out                           = ['/project/3015039.06/bil/virtual/' subjectName '.obob333.dwn' num2str(dwn_sample_freq) '.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'data_virt','-v7.3');
    
    %     svs_parcel_th_tl                    = ft_timelockanalysis(cfg, data_virt);
    %
    %     cfg                                 = [];
    %     cfg.baseline                        = [-.3 -.1];
    %     cfg.baselinetype                    = 'absolute';
    %     svs_parcel_th_tl_bl                 = obob_svs_timelockbaseline(cfg, svs_parcel_th_tl);
    %     svs_parcel_th_tl_bl.avg         	= abs(svs_parcel_th_tl_bl.avg);
    %
    %     cfg                                 = [];
    %     cfg.layout                          = parcellation.layout;
    %     cfg.xlim                            = [-.2 7];
    %     figure; ft_multiplotER(cfg, svs_parcel_th_tl_bl);
    %
    %     load standard_mri_segmented
    %     load('atlas_parcel333.mat');
    %
    %     new_parcellation                    = [];
    %     new_parcellation.parcel_grid.unit   = parcellation.parcel_grid.unit;
    %     new_parcellation.parcel_grid.cfg    = parcellation.parcel_grid.cfg;
    %     i                                   = 0;
    %
    %     for nchan = 1:length(parcellation.parcel_array)
    %         ix  = find(strcmp(parcellation.parcel_array{nchan}.roi_name,data_virt.label));
    %         if ~isempty(ix)
    %             i                                           = i+1;
    %             new_parcellation.parcel_array{i}            = parcellation.parcel_array{nchan};
    %             new_parcellation.parcel_grid.pos(i,:)       = parcellation.parcel_grid.pos(nchan,:);
    %             new_parcellation.parcel_grid.inside(i,:)    = parcellation.parcel_grid.inside(nchan,:);
    %             new_parcellation.parcel_grid.label{i}       = parcellation.parcel_grid.label{nchan};
    %
    %         end
    %     end
    %
    %     new_parcellation.template_grid      = parcellation.template_grid;
    %     new_parcellation.layout             = parcellation.layout;
    %
    %     cfg                                 = [];
    %     cfg.sourcegrid                      = new_parcellation.parcel_grid;
    %     cfg.parameter                       = 'avg';
    %     cfg.latency                         = [0.1 0.3];
    %     cfg.mri                             = mri_seg.bss;
    %     cfg.nanmean                         = 'yes';
    %     svs_parcel_th_interpolated          = obob_svs_virtualsens2source(cfg, svs_parcel_th_tl_bl);
    %
    %     cfg                                 = [];
    %     cfg.funparameter                    = 'avg';
    %     cfg.maskparameter                   = 'brain_mask';
    %     cfg.atlas                           = atlas;
    %     cfg.method                        	= 'surface';
    %     cfg.projmethod                    	= 'nearest';
    %     cfg.camlight                     	= 'no';
    %     cfg.surfinflated                  	= 'surface_inflated_both_caret.mat';
    %     ft_sourceplot(cfg, svs_parcel_th_interpolated);

    
end
