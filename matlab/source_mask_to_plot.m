clear ; clc ;

load ../data/template/template_grid_0.5cm.mat
load ../data/mask/audR.plv.conn.prep21.mask.mat

index_H                             = h_create;

for iside = [1 2]
    
    lst_side                        = {'left','right','both'};
    lst_view                        = [-95 1;95 1;0 50];
    
    z_lim                           = 5;
    
    source.pow                      = repmat(z_lim,length(stat_mask),1);
    source.pos                      = template_grid.pos;
    source.dim                      = template_grid.dim;
    
    source.pow                      = source.pow .* stat_mask;
    
    source.pow(source.pow == 0)     = NaN;
    
    cfg                             =   [];
    cfg.method                      =   'surface';
    cfg.funparameter                =   'pow';
    cfg.funcolorlim                 =   [-z_lim z_lim];
    cfg.opacitylim                  =   [-z_lim z_lim];
    cfg.opacitymap                  =   'rampup';
    cfg.colorbar                    =   'off';
    cfg.camlight                    =   'no';
    cfg.projmethod                  =   'nearest';
    cfg.surffile                    =   ['surface_white_' lst_side{iside} '.mat'];
    cfg.surfinflated                =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    
    ft_sourceplot(cfg, source);
    view(lst_view(iside,:))
    
end