clear;clc;

suj_list                                = [1:33 35:36 38:44 46:51];
load ../data/stock/template_grid_0.5cm.mat;

for nsuj = 1:length(suj_list)
    
    subjectname                         = ['sub' num2str(suj_list(nsuj))];
    
    name_band_time                   	= 'beta.*.p450p1750'; %;'alpha.*.p600p2000'; %'alpha.*.m400m650'; % 
    list_rt                             = {'fast' 'slow'};
    
    for nrt = 1:2
        
        fname_in                        = '~/Dropbox/project_me/data/nback/source/rt/';
        fname_in                        = [fname_in subjectname '.' list_rt{nrt} '.allback.target.' name_band_time '.dicsCombined.mat'];
        flist                           = dir(fname_in);
        fname_in                        = [flist(1).folder filesep flist(1).name];
        
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        
        alldata{nsuj,nrt}               = [];
        alldata{nsuj,nrt}.pow           = source.pow; clear source;
        alldata{nsuj,nrt}.pos           = template_grid.pos;
        alldata{nsuj,nrt}.dim           = template_grid.dim;
        alldata{nsuj,nrt}.inside        = template_grid.inside;
        
        
    end
end

keep alldata name_band_time

%%

close all;

zlimit                                  = 0.2;

cfg                                     = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolorlim                         = [-zlimit zlimit];
cfg.funcolormap                         = brewermap(256,'*RdBu');
cfg.projmethod                          = 'nearest';
cfg.camlight                            = 'no';
cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
list_view                               = [-90 0 0; 90 0 0; 0 0 90];

source_1                                = ft_sourcegrandaverage([],alldata{:,1});
source_2                                = ft_sourcegrandaverage([],alldata{:,2});
source_plot                             = source_1;

source_plot.pow                         = (source_1.pow - source_2.pow) ./ source_2.pow;

switch name_band_time
    case 'alpha.*.m400m650'
        source_plot.pow(source_plot.pow > 0)   	= NaN;
    otherwise
        source_plot.pow(source_plot.pow < 0)   	= NaN;
end

for nview = [1 2]
    
    ft_sourceplot(cfg, source_plot);
    view (list_view(nview,:));
    light ('Position',list_view(nview,:));
    material dull
    
end