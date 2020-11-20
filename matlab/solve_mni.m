clear ; clc ; 

atlas   = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
mri     = ft_read_mri('../fieldtrip-20151124/template/anatomy/single_subj_T1.nii');

load ../data/template/template_grid_0.5cm.mat

source              = [];
source.dim          = template_grid.dim;
source.pos          = template_grid.pos;
source.pow          = ones(length(source.pos),1);

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
source_atlas        = ft_sourceinterpolate(cfg, atlas, source);