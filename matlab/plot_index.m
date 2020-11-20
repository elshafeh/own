clear ; clc ; addpath(genpath('/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/fieldtrip-20151124/')); close all;

load ../data/data_fieldtrip/index/paper_frontal_index.mat
load ../data/template/template_grid_0.5cm.mat

list_roi                    = unique(index_H(:,2));
multip                      = 2;

for nroi = 1:length(list_roi)
    
    where_vox                                   = index_H(index_H(:,2) == list_roi(nroi));
    
    source                                      = [];
    source.pos                                  = template_grid.pos ;
    source.dim                                  = template_grid.dim ;
    source.pow                                  = nan(length(source.pos),1);
    
    source.pow(where_vox,1)                     = 1; % nroi * multip;
    
    z_lim                                       = 2; % length(list_roi)*multip;
    
    cfg                                         =   [];
    cfg.method                                  =   'surface';
    cfg.funparameter                            =   'pow';
    cfg.funcolorlim                             =   [0 z_lim];
    cfg.opacitylim                              =   [0 z_lim];
    cfg.opacitymap                              =   'rampup';
    cfg.colorbar                                =   'off';
    cfg.camlight                                =   'no';
    cfg.projmethod                              =   'nearest';
    cfg.surffile                                =   'surface_white_right.mat';
    cfg.surfinflated                            =   'surface_inflated_right_caret.mat';
    ft_sourceplot(cfg, source);
    view ([95 1])
    title(['roi ' num2str(list_roi(nroi))]);
    cfg.surffile                                =   'surface_white_left.mat';
    cfg.surfinflated                            =   'surface_inflated_left_caret.mat';
    ft_sourceplot(cfg, source);
    view ([-95 1])
    title(['roi ' num2str(list_roi(nroi))]);
    
    close all;
    
end
