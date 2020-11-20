clear ; clc ;

suj = 'yc2' ;

fIN = ['../data/polhemus/' suj '.polh.pos'];

polhemus = ft_read_headshape(fIN);

load(['../data/' suj '/headfield/' suj '.VolGrid.5mm.mat']);

cfg                 = [];
cfg.grid            = grid;
cfg.headmodel       = vol;
cfg.elec            = sens;

leadfield           = ft_prepare_leadfield(cfg);