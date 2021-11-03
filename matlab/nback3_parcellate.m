clear;

clear ; clc ; close all;

% load in atlas

dir_field               = '~/github/fieldtrip/template/atlas/aal/';
atlas                	= ft_read_atlas([dir_field 'ROI_MNI_V4.nii']);
atlas.tissuelabel   	= atlas.tissuelabel';
atlas_param            	= 'tissue';
atlas               	= ft_convert_units(atlas,'cm');

load ../data/stock/template_grid_0.5cm.mat

% create source structure to interpolate the atlas onto

source                 	= [];
source.pos            	= template_grid.pos ;
source.inside         	= template_grid.inside ;
source.dim             	= template_grid.dim ;
source.pow            	= randi(100,[length(source.pos) 1]);

cfg                  	= [];
cfg.interpmethod      	= 'nearest'; % 
cfg.parameter         	= 'pow';
source_atlas         	= ft_sourceinterpolate(cfg, source, atlas);

cfg                     = [];
cfg.parameter           = 'pow';
source_parcellate       = ft_sourceparcellate(cfg,source_atlas,atlas);