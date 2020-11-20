clear ; clc ; 

load ../data_fieldtrip/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = rand(length(source.pos),1);

cfg                                         =   [];
cfg.method                                  =   'glassbrain';
cfg.funparameter                            =   'pow';
% cfg.funcolorlim                             =   [0 10];
% cfg.opacitylim                              =   [0 10];
% cfg.opacitymap                              =   'rampup';
% cfg.colorbar                                =   'off';
% cfg.camlight                                =   'no';
% cfg.projmethod                              =   'nearest';
% cfg.surffile                                =   'surface_white_both.mat';
% cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);