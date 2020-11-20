clear ; clc ;

load ../data/template/template_grid_2cm.mat

source                                      = [];
source.pos                                  = template_grid.pos ;
source.dim                                  = template_grid.dim ;
source.pow                                  = 1:length(source.pos);

z_lim                                       = length(source.pos);
iside                                       = 3;
lst_side                                    = {'left','right','both'};
lst_view                                    = [-95 1;95 11;0 50];

cfg                                         =   [];
cfg.method                                  =   'surface';
cfg.funparameter                            =   'pow';
% cfg.funcolorlim                             =   [0 z_lim];
% cfg.opacitylim                              =   [0 z_lim];
cfg.opacitymap                              =   'rampup';
cfg.colorbar                                =   'off';
cfg.camlight                                =   'no';
cfg.projmethod                              =   'nearest';
cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
ft_sourceplot(cfg, source);
view(lst_view(iside,:))