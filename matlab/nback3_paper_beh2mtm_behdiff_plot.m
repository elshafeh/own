clear;clc;

suj_list                                = [1:33 35:36 38:44 46:51];
load ../data/stock/template_grid_0.5cm.mat;

for nsuj = 1:length(suj_list)
    
    subjectname                         = ['sub' num2str(suj_list(nsuj))];
    list_band                           = {'alpha' 'beta'};
    list_rt                             = {'fast' 'slow'};
    
    for nband = 1:2
        
        for nrt = 1:2
            
            fname_in                    = '~/Dropbox/project_me/data/nback/source/rt/';
            
            % p700p1000 m300m600
            fname_in                    = [fname_in subjectname '.' list_rt{nrt} '.allback.target.' list_band{nband} '.*.m300m600.dicsCombined.mat'];
            flist                       = dir(fname_in);
            fname_in                    = [flist(1).folder filesep flist(1).name];
            
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            tmp{nrt}                   	= source.pow;% ./ source.noise; clear source;
            
            
        end
        
        
        alldata{nsuj,nband}              = [];
        alldata{nsuj,nband}.pow          = tmp{1} ./ tmp{2}; clear tmp;
        alldata{nsuj,nband}.pos          = template_grid.pos;
        alldata{nsuj,nband}.dim          = template_grid.dim;
        alldata{nsuj,nband}.inside       = template_grid.inside;
        
        
    end
end

keep alldata

%%

close all;

zlimit                                  = 0.1;

cfg                                     = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolorlim                         = [-zlimit zlimit];
cfg.funcolormap                         = brewermap(256,'*BuPu'); 
cfg.projmethod                          = 'nearest';
cfg.camlight                            = 'no';
cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
list_view                               = [-90 0 0; 90 0 0; 0 0 90];

source_1                                = ft_sourcegrandaverage([],alldata{:,1});
source_2                                = ft_sourcegrandaverage([],alldata{:,2});
source_plot                             = source_1;

source_plot.pow                         = (source_1.pow - source_2.pow);
source_plot.pow(source_plot.pow > 0)   	= NaN;

for nview = [1 2]
    
    ft_sourceplot(cfg, source_plot);
    view (list_view(nview,:));
    light ('Position',list_view(nview,:));
    material dull
    
end