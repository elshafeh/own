clear ; close all;

suj_list              	= 41:42;

for nsuj = 1:length(suj_list)
    
    load ../data/stock/template_grid_0.5cm.mat
    
    fname_vol           = ['~/Dropbox/project_me/data/nback/source/hdm/hdm_' num2str(suj_list(nsuj)) '.mat'];
    fprintf('\nLoading %s\n',fname_vol);
    load(fname_vol);
    
    fname_mri           = ['~/Dropbox/project_me/data/nback/source/mri/mri_' num2str(suj_list(nsuj)) '.mat'];
    fprintf('\nLoading %s\n',fname_mri);
    load(fname_mri);
    
    cfg                 = [];
    cfg.grid.method     ='basedonmni';
    cfg.grid.template   = template_grid;
    cfg.grid.nonlinear  = 'yes'; % use non-linear normalization
    cfg.mri             = mri;
    grid                = ft_prepare_sourcemodel(cfg);
    grid.MNI_pos        = template_grid.pos;
    
    fname             	= ['~/Dropbox/project_me/data/nback/source/volgrid/sub' num2str(suj_list(nsuj)) '.volgrid.0.5cm.mat'];
    fprintf('\nsaving %s\n',fname);
    save(fname,'vol','grid');
    
    
end