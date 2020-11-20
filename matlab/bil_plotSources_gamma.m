clear ; clc; close all;

if isunix
    project_dir                             = '/project/3015079.01/';
else
    project_dir                             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    
    list_cond                               = {'correct.pre' 'correct.retro'};
    list_window                             = {'m500m100'};
    list_bsl                                = {'p3400p3800'};
    
    for ncond    = 1:length(list_cond)
        for ntime = 1:length(list_window)
            
            list_time                    	= {list_bsl{ntime},list_window{ntime}};
            
            load('../data/stock/template_grid_0.5cm.mat');
            
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.60t100Hz.'  ...
                list_time{1} '.' list_cond{ncond} '.BetaReconDics.mat'];
            fprintf('loading %s\n',fname);
            load(fname); bsl = source; clear source;
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.60t100Hz.' ...
                list_time{2} '.' list_cond{ncond} '.BetaReconDics.mat'];
            fprintf('loading %s\n',fname);
            load(fname); act = source; clear source;
            
            source                      	= [];
            source.pos                   	= template_grid.pos;
            source.dim                  	= template_grid.dim;
            source.pow                    	= (act - bsl) ./ bsl;
            
            alldata{nsuj,ncond}             = source;
            
        end
    end
    
    newdata{nsuj,1}                         = alldata{nsuj,1};
    newdata{nsuj,1}.pow                 	= alldata{nsuj,1}.pow - alldata{nsuj,2}.pow;
    
    
end

clearvars -except alldata list_* newdata

cfg                                         = [];
cfg.method                                  = 'surface';
cfg.funparameter                            = 'pow';
cfg.maskparameter                           = cfg.funparameter;
cfg.funcolorlim                             = [-0.05 0];%
cfg.funcolormap                             = brewermap(256,'*Blues'); % brewermap(256,'Reds');
cfg.projmethod                              = 'nearest';
cfg.camlight                                = 'no';
cfg.surfinflated                            = 'surface_inflated_both_caret.mat';
list_view                                   = [-90 0 0; 90 0 0; 0 0 90];

for nview = [1 2 3]
    
    ft_sourceplot(cfg, ft_sourcegrandaverage([],newdata{:}));
    view (list_view(nview,:));
    light ('Position',list_view(nview,:));
    material dull
    saveas(gcf,['../figures/bil/source/gamma/pre.retro.conrast.v' num2str(nview) '.png']);
    close all;
    
end