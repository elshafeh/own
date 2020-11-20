function h_quickERP_plot(avg)

cfg                                     = [];
cfg.layout                              = 'CTF275_helmet.mat';
cfg.ylim                                = [-1e-13 1e-13];
cfg.marker                              = 'off';
cfg.comment                             = 'no';
cfg.colormap                            = brewermap(256, '*RdYlBu');
cfg.colorbar                            = 'no';
% cfg.channel                             = 'M*O*';
cfg.baseline                            = [-0.1 0];
ft_singleplotER(cfg, avg);