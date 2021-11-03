clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                           	= [1:33 35:36 38:44 46:51]; % []
load ../data/stock/template_grid_0.5cm.mat ;

for nsuj = 1:length(suj_list)
    
    subjectname                  	= ['sub' num2str(suj_list(nsuj))];
    
    list_time                       = {'m200m100ms' 'p70p170ms'};{'m300m100ms' 'p50p250ms'};
    
    tmp                             = [];
    
    for ntime = [1 2]
        
        fname_out                   = ['~/Dropbox/project_me/data/nback/source/lcmv/' subjectname '.allback.allstim'];
        fname_out                	= [fname_out '.' list_time{ntime} '.lcmvCombined.mat'];
        fprintf('\nLoading %s',fname_out);
        
        load(fname_out);
        
        tmp(:,ntime)              	= source; clear source;
        
    end
    
    source                          = [];
    source.pos                      = template_grid.pos;
    source.dim                      = template_grid.dim;
    source.pow                      = (tmp(:,2) - tmp(:,1)) ./ tmp(:,1);
    
    alldata{nsuj,1}                 = source; clear source act bsl;
    
end

keep alldata

%%

source_plot                        	= ft_sourcegrandaverage([],alldata{:});

zlimit                              = 0.1;

cfg                              	= [];
cfg.method                        	= 'surface';
cfg.funparameter                  	= 'pow';
cfg.maskparameter                	= cfg.funparameter;
cfg.funcolorlim                  	= [-zlimit zlimit];
cfg.funcolormap                   	= brewermap(256,'*RdBu');
cfg.projmethod                    	= 'nearest';
cfg.camlight                     	= 'no';
cfg.surfinflated                  	= 'surface_inflated_both_caret.mat';
cfg.colorbar                        = 'no';
% cfg.projthresh                      = 0.6;
list_view                           = [-90 0 0; 90 0 0; 0 0 90];

for nview = [1 3]
    
    ft_sourceplot(cfg,source_plot);
    view (list_view(nview,:));
    light ('Position',list_view(nview,:));
    material dull

end
    