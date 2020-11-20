clear ; clc; close all;

if isunix
    project_dir                         = '/project/3015079.01/';
else
    project_dir                         = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)-1
    
    subjectName                         = suj_list{nsuj};
    list_window                         = {'1stgabor' '2ndgabor'}; % '1stcue','2ndcue'
    ext_bsl                             = 'baseline';
    
    for ntime = 1:length(list_window)
        
        list_time                    	= {ext_bsl,list_window{ntime}};
        
        load('../data/stock/template_grid_0.5cm.mat');
        
        ext_source                      = '5Hz.pccsource';
        
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
        source.pow                    	= (act - bsl);% ./ bsl;
        
        alldata{nsuj,ntime}           	= source; clear source act bs;
        
    end
end
clearvars -except alldata list_window

cfg                                     = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolorlim                         = 'zeromax';
cfg.funcolormap                         = brewermap(256,'Reds');
cfg.projmethod                          = 'nearest';
cfg.camlight                            = 'no';
cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
cfg.projthresh                          = 0.6;

list_view                               = [-90 0 0; 90 0 0; 0 0 90];

for ntime = 1:size(alldata,2)
    for nview = [3]
        
        
        ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:,ntime}));
        view (list_view(nview,:));
        %         light ('Position',list_view(nview,:));
        %         material dull
        title(list_window{ntime});
        
    end
end