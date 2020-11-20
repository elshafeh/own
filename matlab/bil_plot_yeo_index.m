clear ;close all;

load ../data/stock/template_grid_0.5cm.mat
load ../data/index/yeo_index4bil.mat

source               	= [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.inside           = template_grid.inside;

roi_interest            = [4 6 12 10 15];

for d = 1:length(roi_interest)
    
    source.pow       	= nan(length(source.pos),1);
    tmp              	= index_vox(index_vox(:,2) == roi_interest(d),1);
    
    source.pow(tmp)     = 3;
    
    cfg                 = [];
    cfg.method          = 'surface';
    cfg.funparameter    = 'pow';
    cfg.funcolormap     = 'jet';
    cfg.projmethod      = 'nearest';
    cfg.surfinflated    = 'surface_inflated_both_caret.mat';
    cfg.camlight        = 'no';
    cfg.funcolorlim     = [1 4];
    ft_sourceplot(cfg, source);
    material dull
    view([-90 0]);
    title(index_name{roi_interest(d)});
    
    fname_out           = ['D:/Dropbox/project_me/pub/Presentations/bil_update_april/_figures/index/'];
    fname_out           = [fname_out 'roi' num2str(roi_interest(d)) '.view1.png'];
    saveas(gcf,fname_out);
    
    ft_sourceplot(cfg, source);
    material dull
    view([90 0]);
    title(index_name{roi_interest(d)});
    
    fname_out           = ['D:/Dropbox/project_me/pub/Presentations/bil_update_april/_figures/index/'];
    fname_out           = [fname_out 'roi' num2str(roi_interest(d)) '.view2.png'];
    saveas(gcf,fname_out);
    
end