clear ; clc ; close all;

dir_field                       = '~/github/fieldtrip/template/atlas/aal/';
atlas                           = ft_read_atlas([dir_field 'ROI_MNI_V4.nii']);
atlas.tissuelabel               = atlas.tissuelabel';
atlas_param                     = 'tissue';
atlas                           = ft_convert_units(atlas,'cm');

load ../data/stock/template_grid_0.1cm.mat

source                          = [];
source.pos                      = template_grid.pos ;
source.inside               	= template_grid.inside ;
source.dim                      = template_grid.dim ;
source.pow                      = zeros(length(source.pos),1);

templatefile                    = '~/github/fieldtrip/template/anatomy/single_subj_T1.nii';
template_mri                    = ft_read_mri(templatefile);

cfg                             = [];
cfg.voxelcoord                  = 'no';
cfg.parameter                   = 'pow';
cfg.interpmethod                = 'nearest';
source_int                      = ft_sourceinterpolate(cfg, source, template_mri);

cfg                             = [];
parcel                          = ft_sourceparcellate(cfg, source_int, atlas);