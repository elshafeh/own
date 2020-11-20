clear ; clc; close all;

if isunix
    project_dir                             = '/project/3015079.01/';
else
    project_dir                             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    
    list_window                             = {'p3500p4500' 'p4500p5000' 'p5000p6000'};
    list_bsl                                = {'m1200m200' 'm700m200' 'm1200m200'};
    
    for ntime = 1:length(list_window)
        for nbin    = 1:5
            list_time                    	= {list_bsl{ntime},list_window{ntime}};
            
            load('../data/stock/template_grid_0.5cm.mat');
            
            ext_source                      = ['2t4Hz.bin' num2str(nbin) '.pccsource'];
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.itc.'  ...
                list_time{1} '.' ext_source '.mat'];
            fprintf('loading %s\n',fname);
            load(fname); bsl = plf; clear plf;
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.itc.' ...
                list_time{2} '.' ext_source '.mat'];
            fprintf('loading %s\n',fname);
            load(fname); act = plf; clear plf;
            
            source                      	= [];
            source.pos                   	= template_grid.pos;
            source.dim                  	= template_grid.dim;
            source.pow                    	= (act); % - bsl); % ./ bsl;
            
            tmp{nbin}                       = source;
            
            clear source act bsl;
            
        end
        
        alldata{nsuj,ntime}                 = tmp{1};
        alldata{nsuj,ntime}.pow          	= tmp{1}.pow - tmp{5}.pow; clear tmp;
        
        
    end
end

clearvars -except alldata list_window allpoints;
close all;

cfg                                     = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolormap                         = brewermap(256,'Reds');
cfg.projmethod                          = 'nearest';
cfg.camlight                            = 'no';
cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
cfg.projthresh                          = 0.5;

list_view                               = [-90 0 0; 90 0 0; 0 0 90];
list_z                                  = [0.05 0.1 0.1];

for ntime = 1:size(alldata,2)
    for nview = [1 2 3]
        
        cfg.funcolorlim              	= 'zeromax'; %[0 list_z(ntime)];
        ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:,ntime}));
        view (list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title([list_window{ntime}]);
        
    end
end