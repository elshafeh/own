clear ; clc ;

load ../data/stat/L1N1.7t13Hz.p350p650.stat.mat

stat.mask                     = stat.prob < 0.05;
index_H                       = h_createIndexfieldtrip(stat.pos,'../fieldtrip-20151124/');

index_mask                    = index_H(index_H(:,2) == 80 | index_H(:,2) == 82,1);
stat.mask(:)                  = 0;

stat.mask(index_mask)         = 1;

source                        = [];
source.pos                    = stat.pos;
source.dim                    = stat.dim;
tpower                        = stat.stat .* stat.mask;

tpower(tpower == 0)           = NaN;

source.pow                    = tpower ; clear tpower;

cfg                           =   [];
cfg.method                    =   'surface';
cfg.funparameter              =   'pow';
cfg.funcolorlim               =   [-3 3];
cfg.opacitylim                =   [-3 3];
cfg.opacitymap                =   'rampup';
cfg.colorbar                  =   'off';
cfg.camlight                  =   'no';
cfg.projmethod                =   'nearest';
cfg.surffile                  =   'surface_white_both.mat';
cfg.surfinflated              =   'surface_inflated_both_caret.mat';

ft_sourceplot(cfg, source);