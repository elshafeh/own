clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
else
    project_dir                     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)-1
    
    subjectName                         = suj_list{nsuj};
    list_window                         = {'m0p100ms' 'p200p300ms' 'p300p400ms' 'p400p500ms' 'p500p600ms' 'p600p700ms' 'p700p800ms' 'p800p900ms' 'p900p1000ms' ... 
        'p1000p1100ms' 'p1100p1200ms' 'p1200p1300ms' 'p1300p1400ms' 'p1400p1500ms'};
    
    ext_bsl                             = 'm200m100ms'; 
    
    for ntime = 1:length(list_window)
        
        list_time                    	= {ext_bsl,list_window{ntime}};
        
        load('../data/stock/template_grid_0.5cm.mat');
        
        ext_source                      = 'lcmvsource';
        dir_in                          = 'I:\bil\source\';
        
        ext_lock                        = '.1stcue.lock.';
        
        fname                           = [dir_in subjectName ext_lock list_time{1} '.' ext_source '.mat'];
        fprintf('loading %s\n',fname);
        load(fname); bsl = source; clear source;
        
        fname                           = [dir_in subjectName ext_lock list_time{2} '.' ext_source '.mat'];
        fprintf('loading %s\n',fname);
        load(fname); act = source; clear source;
        
        source                      	= [];
        source.pos                   	= template_grid.pos;
        source.dim                  	= template_grid.dim;
        source.pow                    	= abs((act - bsl) ./ bsl);
        
        alldata{nsuj,ntime}           	= source; clear source act bs;
        
    end
end

clearvars -except alldata list_window; close all;

cfg                              	= [];
cfg.method                        	= 'surface';
cfg.funparameter                  	= 'pow';
cfg.maskparameter                	= cfg.funparameter;
cfg.funcolorlim                  	= 'zeromax'; %[0 0.1]; %
cfg.funcolormap                   	= brewermap(256,'Reds');
cfg.projmethod                    	= 'nearest';
cfg.camlight                     	= 'no';
cfg.surfinflated                  	= 'surface_inflated_both_caret.mat';
% cfg.projthresh                      = 0.7;
list_view                           = [-90 0 0; 90 0 0; 0 0 90];

for nview = [1 2]
    for ntime = 1:size(alldata,2)
        
        ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:,ntime}));
        view (list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title(list_window{ntime});
        
    end
end