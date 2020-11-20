function h_seeyourvoxels(index,source_pos,z_lim)

source.pos          = source_pos;
source.pow          = zeros(length(source.pos),1);

for n = 1:length(index)
    source.pow(index(n),:) = n;
end



for iside = 3
    
    lst_side                                    = {'left','right','both'};
    lst_view                                    = [-95 1;95,11;0 50];
    
    cfg                                         =   [];
    cfg.funcolormap                             =   'jet';
    cfg.method                                  =   'surface';
    cfg.funparameter                            =   'pow';
    cfg.funcolorlim                             =   [0 z_lim];
    cfg.opacitylim                              =   [0 z_lim];
    cfg.opacitymap                              =   'rampup';
    cfg.colorbar                                =   'off';
    cfg.camlight                                =   'no';
    cfg.projthresh                              =   0.2;
    cfg.projmethod                              =   'nearest';
    cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
    cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    ft_sourceplot(cfg, source);
    view(lst_view(iside,:))
    
end
