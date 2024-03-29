clear;clc;

suj_list                                = [1:33 35:36 38:44 46:51];
load ../data/stock/template_grid_0.5cm.mat;

for nsuj = 1:length(suj_list)
    
    subjectname                         = ['sub' num2str(suj_list(nsuj))];
    
    name_band                           = 'beta'; %'alpha';% 
    name_time                           = 'p600p1100'; % 'p200p2000';
    
    for nback = 1:2
        
        fname_in                        = '~/Dropbox/project_me/data/nback/source/load/';
        fname_in                        = [fname_in subjectname '.' num2str(nback) 'back.allstim.' name_band '.*.' name_time '.dicsCombined.mat'];
        flist                           = dir(fname_in);
        fname_in                        = [flist(1).folder filesep flist(1).name];
        
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        
        alldata{nsuj,nback}              = [];
        alldata{nsuj,nback}.pow          = source.pow; clear source;
        alldata{nsuj,nback}.pos          = template_grid.pos;
        alldata{nsuj,nback}.dim          = template_grid.dim;
        alldata{nsuj,nback}.inside       = template_grid.inside;
        
        
    end
end

keep alldata

%%

close all;

zlimit                                  = 0.15;

cfg                                     = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolorlim                         = [-zlimit zlimit];
cfg.funcolormap                         = brewermap(256,'*PuOr');
cfg.projmethod                          = 'nearest';
cfg.camlight                            = 'no';
cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
list_view                               = [-90 0 0; 90 0 0; 0 0 90];

source_1                                = ft_sourcegrandaverage([],alldata{:,1});
source_2                                = ft_sourcegrandaverage([],alldata{:,2});
source_plot                             = source_1;

source_plot.pow                         = (source_1.pow - source_2.pow) ./ source_2.pow;
source_plot.pow(source_plot.pow < 0)   	= NaN;

for nview = [1 2]
    
    ft_sourceplot(cfg, source_plot);
    view (list_view(nview,:));
    light ('Position',list_view(nview,:));
    material dull
    
end