clear ; clc; close all;

if isunix
    project_dir                             = '/project/3015079.01/';
else
    project_dir                             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat;
load ../data/stock/template_grid_0.5cm.mat;

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    sub_avg                                 = [];
    
    for nbin    = 1:5
        
        ext_source                          = 'ThetaDics';
        list_window                         = 'p2300p4100';
        fname                               = dir([project_dir 'data/' subjectName '/source/*.3t5Hz.' list_window '.itcbin' num2str(nbin) '.' ext_source '.mat']);
        fname                               = [fname(1).folder filesep fname(1).name];
        fprintf('loading %s\n',fname);
        load(fname); act = source; clear source;
        
        sub_avg                            	= [sub_avg act];
        
        source                              = [];
        source.pos                          = template_grid.pos;
        source.dim                          = template_grid.dim;
        source.pow                          = (act); 
        
        alldata{nsuj,nbin}                  = source;
        
    end
    
    sub_avg                                 = nanmean(sub_avg,2);
    
    %     for nbin = 1:5
    %         alldata{nsuj,nbin}.pow              = (alldata{nsuj,nbin}.pow - sub_avg) ./ sub_avg;
    %     end
    
    clear sub_avg;
    
end

clearvars -except alldata ext_source list_window

%%

zlimit                                  = 0.12;

cfg                                     = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolorlim                         = [-zlimit zlimit];
cfg.funcolormap                         = brewermap(256,'RdBu'); 
cfg.projmethod                          = 'nearest';
cfg.camlight                            = 'no';
cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
list_view                               = [-90 0 0; 90 0 0; 0 0 90];

source_1                                = ft_sourcegrandaverage([],alldata{:,1});
source_2                                = ft_sourcegrandaverage([],alldata{:,5});
source_plot                             = source_1;

source_plot.pow                         = (source_1.pow - source_2.pow) ./ source_1.pow;
source_plot.pow(source_plot.pow < 0)   	= NaN;

for nview = [1 2 3]
    
    ft_sourceplot(cfg, source_plot);
    view (list_view(nview,:));
    light ('Position',list_view(nview,:));
    material dull
    title([ext_source ' ' list_window]);
    saveas(gcf,['D:\Dropbox\project_me\pub\Papers\postdoc\bilbo_manuscript_v1\_figures\_prep\source\tf\' ext_source '.' list_window '.b1vb5.' num2str(nview) '.png']);
    
end