clear ; close all;

addpath('/Users/heshamelshafei/Documents/GitHub/obob_ownft/');
obob_init_ft;

cfg                             = [];
cfg.resolution                  = 5/1000;
[parcellation, template_grid]   = obob_svs_create_parcellation(cfg);

keep parcellation template_grid

save ../data/stock/obob_parcellation_grid_5mm.mat;