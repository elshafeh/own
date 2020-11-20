clear ; clc ;

% for list = {'Auditory.nii.gz','prim_Visual.nii.gz','RECN.nii.gz','LECN.nii.gz','high_Visual.nii.gz','Visuospatial.nii.gz'}

atlas = ft_read_atlas(['/Users/heshamelshafei/Downloads/Functional_ROIs/Visuospatial.nii.gz']);

load ../data/template/template_grid_5mm.mat

source              = [];
source.pos          = template_grid.pos;
source.pow          = ones(length(source.pos),1);

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'brick0';
source_atlas        = ft_sourceinterpolate(cfg, atlas, source);

source.pow          = source_atlas.brick0;

reg_list = h_findNonEmptyVoxels(source);

new_source          = source;
new_source.pow      = source_atlas.brick0;
new_source.pow(new_source.pow  == 0) = NaN;

iside = 3;

lst_side                = {'left','right','both'};
lst_view                = [-95 1;95,11;0 50];

z_lim                   = 2;

cfg                     =   [];
cfg.funcolormap         = 'jet';
cfg.method              =   'surface';
cfg.funparameter        =   'pow';
cfg.funcolorlim         =   [-z_lim z_lim];
cfg.opacitylim          =   [-z_lim z_lim];
cfg.opacitymap          =   'rampup';
cfg.colorbar            =   'off';
cfg.camlight            =   'no';
cfg.projthresh          =   0.2;
cfg.projmethod          =   'nearest';
cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];

ft_sourceplot(cfg, new_source);
view(lst_view(iside,:))