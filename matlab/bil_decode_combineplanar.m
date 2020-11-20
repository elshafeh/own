clear;

suj_list                = {'sub003'};

for n = 1:length(suj_list)
    tic;
    
    suj                 = suj_list{n};
    
    
    dir_data            = ['../data/' suj '/preproc/'];
    fname               = [dir_data suj '_gratingLock_dwnsample100Hz.mat'];
    
    fprintf('Loading %s\n',fname);
    load(fname);
    
    data_axial          = data; clear data;
    
    cfg                 = [];
    cfg.feedback        = 'no';
    cfg.method          = 'template';
    cfg.planarmethod    = 'sincos';
    cfg.channel         = {'MEG'};
    cfg.trials          = 'all';
    cfg.neighbours      = ft_prepare_neighbours(cfg, data_axial);
    
    data_planar         = ft_megplanar(cfg,data_axial);
    
    cfg                 = [];
    cfg.method          = 'sum';
    data                = ft_combineplanar(cfg,data_planar);
    
    data_axial.trial    = data.trial;
    data                = data_axial;
    
    clear data_axial data_planar
    
    fname               = [dir_data suj '_gratingLock_dwnsample100Hz_planarcombined.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'data','-v7.3');
    
    clc;toc;
    
    clear data* ; 
    
end