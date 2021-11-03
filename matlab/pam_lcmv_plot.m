clear ; clc;

load ../data/stock/template_grid_0.5cm.mat ;

for nsuj = 2:21
    
    subjectName                	= ['yc' num2str(nsuj)];
    
    %     list_time               	= {'CnD.m200m0ms' 'CnD.m0p200ms'};
    %     list_time               	= {'nDRT.m0p200ms' 'nDLT.m0p200ms'}; % {'nDLT.m200m0ms' 'nDRT.m0p200ms'};
    
    list_time               	= {'nBP.m600m100ms' 'nBP.m100p400ms'};
    
    dir_in                      = '~/Dropbox/project_me/data/pam/source/';
    fname_in                    = [dir_in subjectName '.' list_time{1} '.lcmvsource.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    bsl                         = source; % abs(source);
    
    fname_in                    = [dir_in subjectName '.' list_time{2} '.lcmvsource.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    act                         = source; % abs(source);
    
    
    source                    	= [];
    source.pos                 	= template_grid.pos;
    source.dim                	= template_grid.dim;
    source.pow                	= (act-bsl) ./ (bsl);
    
    alldata{nsuj-1,1}         	= source; clear source act bsl;
    
end

keep alldata

%%

close all;

source_plot                     = ft_sourcegrandaverage([],alldata{:});
zlimit                          = 0.1;

cfg                          	= [];
cfg.method                   	= 'surface';
cfg.funparameter              	= 'pow';
cfg.maskparameter            	= cfg.funparameter;
cfg.funcolorlim               	= [-zlimit zlimit];%'maxabs'; %
cfg.funcolormap              	= brewermap(256,'*RdBu');
cfg.projmethod               	= 'nearest';
cfg.camlight                   	= 'no';
cfg.surfinflated             	= 'surface_inflated_both_caret.mat';
cfg.colorbar                   	= 'no';
% cfg.projthresh               	= 0.5;
list_view                     	= [-90 0 0; 90 0 0; 0 0 90];

for nview = [3]
    
    ft_sourceplot(cfg,source_plot);
    view (list_view(nview,:));
    light ('Position',list_view(nview,:));
    material dull

end