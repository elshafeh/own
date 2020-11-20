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
    
    band_name                               = 'BetaReconDics';
        
    switch band_name
        case 'ThetaReconDics'
            list_window                  	= {'p3700p4700'};
            list_bsl                       	= {'m600m200'};
        case 'AlphaReconDics'
            list_window                    	= {'p350p1000' 'p3000p4000'};
            list_bsl                       	= {'m600m200' 'm600m200'};
        case 'BetaReconDics'
            list_window                    	= {'p340p770' 'p2600p3600' 'p3800p4400'};
            list_bsl                       	= {'m600m200' 'm600m200' 'm600m200'};
    end
            
    for ntime = 1:length(list_window)
        
        list_time                           = {list_bsl{ntime},list_window{ntime}};
        
        for ncond    = 1:length(list_cond)
            
            load('../data/stock/template_grid_0.5cm.mat');
            
            fname                           = dir([project_dir 'data/' subjectName '/source/' subjectName '.*Hz.'  ...
                list_time{1} '.' list_cond{ncond} '.' band_name '.mat']);
            fname                           = [fname(1).folder filesep fname(1).name];
            fprintf('loading %s\n',fname);
            load(fname); bsl = source; clear source;
            
            fname                           = dir([project_dir 'data/' subjectName '/source/' subjectName '.*Hz.' ...
                list_time{2} '.' list_cond{ncond} '.' band_name '.mat']);
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

%%

clearvars -except alldata list_* newdata band_name;
close all;

switch band_name
    case 'ThetaReconDics'
        list_zlim                         	= [-0.07 0.07;-0.07 0.07];
        list_mask                         	= [1];
    case 'AlphaReconDics'
        list_zlim                        	= [-0.15 0.15;-0.15 0.15];
        list_mask                       	= [1 -1];
    case 'BetaReconDics'
        list_zlim                        	= [-0.08 0.08;-0.07 0.07;-0.1 0.1];
        list_mask                       	= [1 -1 1];
end

list_view                                   = [-90 0 0; 90 0 0; 0 0 90];

for ntime = 1:size(alldata,2)
    for nview = [1 2]
        
        dataplot                            = ft_sourcegrandaverage([],alldata{:,ntime});
        
        if list_mask(ntime) == 1
            dataplot.pow(dataplot.pow > 0)  = NaN;
        else
            dataplot.pow(dataplot.pow < 0)  = NaN;
        end
        
        cfg                                 = [];
        cfg.method                      	= 'surface';
        cfg.funparameter                 	= 'pow';
        cfg.maskparameter                 	= cfg.funparameter;
        cfg.funcolormap                 	= brewermap(256,'PRGn');
        cfg.projmethod                   	= 'nearest';
        cfg.camlight                     	= 'no';
        cfg.surfinflated                 	= 'surface_inflated_both_caret.mat';
        cfg.colorbar                        = 'yes';
        cfg.funcolorlim                     = list_zlim(ntime,:);
        
        ft_sourceplot(cfg, dataplot);
        view (list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title([band_name ' ' list_window{ntime}]);
        dir_fig                             = 'D:\Dropbox\project_me\pub\Papers\postdoc\bilbo_manuscript_v1\_figures\_prep\source\pretro\prgn\';
        saveas(gcf,[dir_fig 'pre.retro.conrast.' band_name '.' list_window{ntime} '.v' ...
            num2str(nview) '.png']);
        
    end
end