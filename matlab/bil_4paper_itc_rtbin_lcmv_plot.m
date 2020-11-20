clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
else
    project_dir                     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat
load ../data/stock/template_grid_0.5cm.mat ;

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    list_bin                        = [1 2];
    
    for nbin = 1:length(list_bin)
        
        dir_data                  	= [project_dir 'data/' subjectName '/source/'];
        
        fname                     	= [dir_data subjectName '.cuelock.rtBin' num2str(list_bin(nbin)) '.m600m200ms.lcmvsource.mat'];
        fprintf('loading %s\n',fname);
        load(fname); bsl = source; clear source;
        
        fname                      	= [dir_data subjectName '.cuelock.rtBin' num2str(list_bin(nbin)) '.p3700p5000ms.lcmvsource.mat'];
        fprintf('loading %s\n',fname);
        load(fname); act = source; clear source;
        
        source                    	= [];
        source.pos                 	= template_grid.pos;
        source.dim                	= template_grid.dim;
        source.pow                	= act;
        
        alldata{nsuj,nbin}          = source; clear source act bsl;
        
    end
end

clearvars -except alldata list_window; close all;

%%

close all;

source_1                           	= ft_sourcegrandaverage([],alldata{:,1});
source_2                          	= ft_sourcegrandaverage([],alldata{:,2});
source_plot                        	= source_1;

source_plot.pow                  	= (source_1.pow - source_2.pow) ./ source_1.pow;
source_plot.pow(source_plot.pow < 0)	= NaN;

zlimit                              = 0.05;

cfg                              	= [];
cfg.method                        	= 'surface';
cfg.funparameter                  	= 'pow';
cfg.maskparameter                	= cfg.funparameter;
cfg.funcolorlim                  	= [-zlimit zlimit];
cfg.funcolormap                   	= brewermap(256,'RdBu');
cfg.projmethod                    	= 'nearest';
cfg.camlight                     	= 'no';
cfg.surfinflated                  	= 'surface_inflated_both_caret.mat';
cfg.colorbar                        = 'no';
% cfg.projthresh                      = 0.6;
list_view                           = [-90 0 0; 90 0 0; 0 0 90];

for nview = [1 2]
    
    ft_sourceplot(cfg,source_plot);
    view (list_view(nview,:));
    light ('Position',list_view(nview,:));
    material dull
    saveas(gcf,['D:\Dropbox\project_me\pub\Papers\postdoc\bilbo_manuscript_v1\_figures\_prep\source\lcmv\b1vb5.' num2str(nview) '.png']);

end