clear ; clc; close all;

if isunix
    project_dir                             = '/project/3015079.01/';
else
    project_dir                             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    
    list_cond                               = {'correct.pre','correct.retro'};
    list_window                             = {'p300p1100' 'p1500p3000' 'p2600p4000'};
    list_bsl                                = {'m1000m200' 'm1000m200' 'm1000m200'};
    
    for ntime = 1:length(list_window)
        
        list_time                           = {list_bsl{ntime},list_window{ntime}};
        
        for ncond    = 1:length(list_cond)
            
            load('../data/stock/template_grid_0.5cm.mat');
            
            fname                           = dir([project_dir 'data/' subjectName '/source/' subjectName '.*Hz.'  ...
                list_time{1} '.' list_cond{ncond} '.AlphaReconDics.mat']);
            fname                           = [fname(1).folder filesep fname(1).name];
            fprintf('loading %s\n',fname);
            load(fname); bsl = source; clear source;
            
            fname                           = dir([project_dir 'data/' subjectName '/source/' subjectName '.*Hz.' ...
                list_time{2} '.' list_cond{ncond} '.AlphaReconDics.mat']);
            fname                           = [fname(1).folder filesep fname(1).name];
            fprintf('loading %s\n',fname);
            load(fname); act = source; clear source;
            
            source                      	= [];
            source.pos                   	= template_grid.pos;
            source.dim                  	= template_grid.dim;
            source.pow                    	= (act - bsl) ./ bsl;
            
            tmp{ncond}                      = source; clear act bsl;
            
        end
        
        alldata{nsuj,ntime}                 = tmp{1};
        alldata{nsuj,ntime}.pow          	= tmp{1}.pow - tmp{2}.pow;
        
        
    end
end

clearvars -except alldata list_* newdata; close all;

list_colormap                               = {'*Blues' '*Blues' 'Reds'};
list_zlim                                   = [-0.15 0; -0.03 0; 0 0.06];
list_view                                   = [-90 0 0; 90 0 0; 0 0 90];

for ntime = 1:size(alldata,2)
    for nview = [1 2 3]
        
        
        cfg                                         = [];
        cfg.method                                  = 'surface';
        cfg.funparameter                            = 'pow';
        cfg.maskparameter                           = cfg.funparameter;
        cfg.funcolormap                             = brewermap(256,'Reds'); % brewermap(256,'Reds');
        cfg.projmethod                              = 'nearest';
        cfg.camlight                                = 'no';
        cfg.surfinflated                            = 'surface_inflated_both_caret.mat';
        
        if nview == 3
            cfg.colorbar = 'yes';
        else
            cfg.colorbar = 'no';
        end
        
        cfg.funcolorlim                	= list_zlim(ntime,:);
        cfg.funcolormap               	= brewermap(256,list_colormap{ntime});
        
        ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:,ntime}));
        view (list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title(list_window{ntime});
        dir_fig                             = 'D:\Dropbox\project_me\pub\Presentations\bil update april\_figures\source\alpha\';
        saveas(gcf,[dir_fig 'pre.retro.conrast.' list_window{ntime} '.v' ...
            num2str(nview) '.png']);
        %         close all;
        
    end
end