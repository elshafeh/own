clear ; clc; close all;

if isunix
    project_dir                             = '/project/3015079.01/';
else
    project_dir                             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    
    list_cond                               = {'correct.fast','correct.slow'};
    list_window                             = {'p4500p5500'}; %{'p1000p2000' 'p2000p3000' 'p3000p4000'}; % p4500p5000
    list_bsl                                = {'m1200m200'}; % {'m1200m200' 'm1200m200' 'm1200m200'}; % m1200m200
    
    for ntime = 1:length(list_window)
        
        list_time                           = {list_bsl{ntime},list_window{ntime}};
        
        for ncond    = 1:length(list_cond)
            
            load('../data/stock/template_grid_0.5cm.mat');
            
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.3t5Hz.'  ...
                list_time{1} '.' list_cond{ncond} '.ThetaReconDics.mat'];
            fprintf('loading %s\n',fname);
            load(fname); bsl = source; clear source;
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.3t5Hz.' ...
                list_time{2} '.' list_cond{ncond} '.ThetaReconDics.mat'];
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

clearvars -except alldata list_* newdata

cfg                                         = [];
cfg.method                                  = 'surface';
cfg.funparameter                            = 'pow';
cfg.maskparameter                           = cfg.funparameter;
cfg.funcolorlim                             = [0 0.05];%
cfg.funcolormap                             = brewermap(256,'Reds'); % brewermap(256,'Reds');
cfg.projmethod                              = 'nearest';
cfg.camlight                                = 'no';
cfg.surfinflated                            = 'surface_inflated_both_caret.mat';
list_view                                   = [-90 0 0; 90 0 0; 0 0 90];

for ntime = 1:size(alldata,2)
    for nview = [1 2 3]
        
        if ntime == 1 && nview == 1
            cfg.colorbar = 'yes';
        else
            cfg.colorbar = 'no';
        end
        
        ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:,ntime}));
        view (list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title(list_window{ntime});
        saveas(gcf,['D:\Dropbox\project_me\pub\Presentations\bil update april\_figures\source\theta\fast.slow.conrast.' list_window{ntime} '.v' ...
            num2str(nview) '.png']);
        %         close all;
        
    end
end