clear;

for nsuj = 2:21
    
    sujname                             = ['yc' num2str(nsuj)];
    dir_in                              = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
    
    % load in data
    fname_in                            = [dir_in sujname '.CnD.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    fname                               = [dir_in sujname '.VolGrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                               = [dir_in sujname '.adjusted.leadfield.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                                 = [];
    cfg.channel                         = data_elan.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    % down-sample , this should make files a lot smaller and since we're
    % only interested in alpha - this should be fine
    cfg                                 = [];
    cfg.resamplefs                      = 100;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'no';
    data                                = ft_resampledata(cfg, data_elan); clear data_elan
    
    cfg                                 = [];
    cfg.covariance                      = 'yes';
    cfg.covariancewindow                = [-1 3]; % use values that make more sense
    avg                                 = ft_timelockanalysis(cfg,data);
    
    % -- create spatial filter
    cfg                                 = [];
    cfg.method                          = 'lcmv';
    cfg.sourcemodel                     = leadfield;
    cfg.headmodel                       = vol;
    cfg.lcmv.keepfilter                 = 'yes';
    cfg.lcmv.fixedori                   = 'yes';
    cfg.lcmv.projectnoise               = 'yes';
    cfg.lcmv.keepmom                    = 'yes';
    cfg.lcmv.projectmom                 = 'yes';
    cfg.lcmv.lambda                     = '5%' ;
    source                              =  ft_sourceanalysis(cfg, avg);
    spatialfilter                       =  cat(1,source.avg.filter{:});
    
    load ~/Dropbox/project_me/data/pam/index/pam_alpha_5mm_aal_index.mat
    
    data_virt{1}                        = func_create_virt_pam(data,index_name,index_vox,spatialfilter,'0.5cm');
    
    list_region                         = {'visual' 'auditory' 'motor'};
    
    index_name                          = {};
    index_vox                           = [];
    
    i                                   = 0;
    
    for nregion = [1 2 3]
        
        load(['~/Dropbox/project_me/data/pam/vox/' sujname '.maxvox.' list_region{nregion} '.mat']);
        
        nb_vox                          = 2;
        
        for nv = 1:nb_vox
            i                          	= i + 1;
            index_name{i}             	= [list_region{nregion}(1:3) ' loc L vox' num2str(nv)];
            index_vox                 	= [index_vox; vox_list_l(nv,:).Index i];
            
        end
        
        for nv = 1:nb_vox
            i                         	= i + 1;
            index_name{i}            	= [list_region{nregion}(1:3) ' loc R vox' num2str(nv)];
            index_vox                  	= [index_vox; vox_list_r(nv,:).Index i];
        end
                
    end
    
    data_virt{2}                        = func_create_virt_pam(data,index_name,index_vox,spatialfilter,'0.5cm');
    
    data                                = ft_appenddata([],data_virt{:}); clear data_virt;
    
    fname                               = ['~/Dropbox/project_me/data/pam/virt/' sujname '.CnD.virtualelectrode.mat'];
    fprintf('\nsaving %s\n',fname);
    save(fname,'data','-v7.3');
    
    
end