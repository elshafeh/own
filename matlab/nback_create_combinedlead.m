clear ; close all;

suj_list                                 	= [1:33 35:36 38:44 46:51];

for ns = 2:length(suj_list)
    
    fname                               	= ['J:/temp/nback/data/source/volgrid/sub' num2str(suj_list(ns)) '.volgrid.0.5cm.mat'];
    
    if exist(fname)
        
        fname                            	= '../data/stock/template_grid_0.5cm.mat';
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        fname                               = ['J:/temp/nback/data/source/volgrid/sub' num2str(suj_list(ns)) '.volgrid.0.5cm.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        fname = ['D:\Dropbox\project_nback\data\grad_orig\grad' num2str(suj_list(ns)) '.mat'];
        load(fname);
        
        cfg                                 = [];
        cfg.sourcemodel                   	= grid;
        cfg.headmodel                       = vol;
        cfg.grad                            = grad;
        cfg.channel                         = 'MEG';
        leadfield                           = ft_prepare_leadfield(cfg);
        
        %         cfg                                 = [];
        %         cfg.channel                         = data.label;
        %         leadfield                           = ft_selectdata(cfg,leadfield);
        
        fname                               = ['J:/temp/nback/data/source/lead/sub' num2str(suj_list(ns)) '.combined.leadfield.0.5cm.mat'];
        fprintf('\nsaving %s\n',fname);
        save(fname,'leadfield','-v7.3');
        
    end
end