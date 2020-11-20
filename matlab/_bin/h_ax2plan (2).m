function data_planar = h_ax2plan(data_axial)

cfg                 = [];
cfg.feedback        = 'no';
cfg.method          = 'template';
cfg.template        = '/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/neighbours/neuromag306mag_neighb.mat';
cfg.planarmethod    = 'sincos';
cfg.channel         = 'MEG';
cfg.trials          = 'all';
cfg.neighbours      = ft_prepare_neighbours(cfg, data_axial);

data_planar         = ft_megplanar(cfg,data_axial);