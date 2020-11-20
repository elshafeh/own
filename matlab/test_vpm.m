clear ; 

atlas = ft_read_atlas('/Users/heshamelshafei//Downloads/BNA_MPM_thr25_1.25mm.nii')

vtpm = ft_convert_units(vtpm, 'cm');

load ../data/template/template_grid_5mm.mat

source              = [];
source.pos          = template_grid.pos;

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
source_atlas        = ft_sourceinterpolate(cfg, vtpm, source);

source.pow          = source_atlas.tissue ;

lst_side                = {'left','right','both'};
lst_view                = [-95 1;95,11;0 50];

z_lim                   = 30;

cfg                     =   [];
cfg.funcolormap         =   'jet';
cfg.method              =   'surface';
cfg.funparameter        =   'pow';
cfg.funcolorlim         =   [0 z_lim];
cfg.opacitylim          =   [0 z_lim];
cfg.opacitymap          =   'rampup';
cfg.colorbar            =   'off';
cfg.camlight            =   'no';
cfg.projthresh          =   0.2;
cfg.projmethod          =   'nearest';
cfg.surffile            =   'surface_white_both.mat';
cfg.surfinflated        =   'surface_inflated_both_caret.mat';

ft_sourceplot(cfg,source);

