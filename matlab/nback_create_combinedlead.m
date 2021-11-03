clear ; close all;

suj_list                  	= [1:33 35:36 38:44 46:51];
grid_size                 	= '0.5cm';

for ns = 1:length(suj_list)
    
    fname_vol            	= ['~/Dropbox/project_me/data/nback/source/volgrid/sub' num2str(suj_list(ns)) '.volgrid.' grid_size '.mat'];
    
    if exist(fname_vol)
        
        fname_grid       	= ['../data/stock/template_grid_' grid_size '.mat'];
        fprintf('\nloading %s\n',fname_grid);
        load(fname_grid);
        
        fprintf('\nloading %s\n',fname_vol);
        load(fname_vol);
        
        fname = ['~/Dropbox/project_nback/data/grad_orig/grad' num2str(suj_list(ns)) '.mat'];
        load(fname);
        
        cfg                	= [];
        cfg.sourcemodel   	= grid;
        cfg.headmodel      	= vol;
        cfg.grad          	= grad;
        cfg.channel       	= 'MEG';
        leadfield        	= ft_prepare_leadfield(cfg);
        
        fname           	= ['~/Dropbox/project_me/data/nback/source/lead/sub' num2str(suj_list(ns)) '.combined.leadfield.' grid_size '.mat'];
        fprintf('\nsaving %s\n',fname);
        save(fname,'leadfield','-v7.3');
        
    end
end