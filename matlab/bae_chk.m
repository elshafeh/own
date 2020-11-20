clear ; clc ;

load('../data_fieldtrip/index/0.5cm_NewHighAlphaLateWindowAgeContrast11Rois.mat');

index_H                 = [index_H(:,1) index_H(:,4)];

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for nroi = 1:length(list_H)
    
    source.pos              = template_grid.pos;
    source.dim              = template_grid.dim;
    source.pow              = zeros(length(source.pos),1);
   
    source.pow(index_H(index_H(:,2)==nroi,1),1) = 10;
    
    z_lim                         = 5;
    
    cfg                           =   [];
    cfg.method                    =   'surface';
    cfg.funparameter              =   'pow';
    cfg.funcolorlim               =   [-z_lim z_lim];
    cfg.opacitylim                =   [-z_lim z_lim];
    cfg.opacitymap                =   'rampup';
    cfg.colorbar                  =   'off';
    cfg.camlight                  =   'no';
    cfg.projthresh                =   0.2;
    cfg.projmethod                =   'nearest';
    cfg.surffile                  =   ['surface_white_both.mat'];
    cfg.surfinflated              =   ['surface_inflated_both_caret.mat'];
    
    ft_sourceplot(cfg, source);
    title(list_H{nroi});
    
end