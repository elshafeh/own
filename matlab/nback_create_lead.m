clear ; close all;

list_suj                                        = [1:33 35:36 38:44 46:51];

for ns = 1:length(list_suj)
    
    fname                                       = ['J:/temp/nback/data/source/volgrid/sub' num2str(list_suj(ns)) '.volgrid.0.5cm.mat'];
    
    if ~exist(fname)
        
        fname                                   = '../data/stock/template_grid_0.5cm.mat';
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        fname                               	= ['J:/temp/nback/data/source/mri/mri_' num2str(ns) '.mat'; ];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        [vol, grid]                             = h_create_normalisedHeadmodel(mri,template_grid); clear fname;
        
        fname                                   = ['J:/temp/nback/data/source/volgrid/sub' num2str(list_suj(ns)) '.volgrid.0.5cm.mat'];
        fprintf('\nsaving %s\n',fname);
        save(fname,'vol','grid');
        
        for nsession = 1:2
            
            % load data
            fname                               = ['K:/nback/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(list_suj(ns)) '.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            cfg                                 = [];
            cfg.grid                            = grid;
            cfg.headmodel                       = vol;
            cfg.grad                            = data.grad;
            cfg.channel                         = 'MEG';
            leadfield                           = ft_prepare_leadfield(cfg);
            
            cfg                                 = [];
            cfg.channel                         = data.label;
            leadfield                           = ft_selectdata(cfg,leadfield);
            
            fname                               = ['J:/temp/nback/data/source/lead/sub' num2str(list_suj(ns)) '.session' num2str(nsession) '.leadfield.0.5cm.mat']; 
            
            fprintf('\nsaving %s\n',fname);
            save(fname,'leadfield','-v7.3');
            
        end
    end
end