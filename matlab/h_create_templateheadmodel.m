function [template_vol,template_grid] = h_create_templateheadmodel(template_mri_name,vox_size)

template            = ft_read_mri(template_mri_name);
template.coordsys   = 'spm';

fprintf('Segment the template brain\n')

% segment the template brain and construct a volume conduction model (i.e. head model)

cfg                 = [];
template_seg        = ft_volumesegment(cfg, template);

fprintf('Construct a template volume conduction model\nSingleshell method\n')
cfg                 = [];
cfg.method          = 'singleshell';
template_vol        = ft_prepare_headmodel(cfg, template_seg);
template_vol        = ft_convert_units(template_vol, 'cm');

fprintf('Construct the dipole grid in the template brain\n')

%construct the dipole grid in the template brain coordinates the source units are in cm
cfg                 = [];
cfg.grid.xgrid      = -20:vox_size:20;
cfg.grid.ygrid      = -20:vox_size:20;
cfg.grid.zgrid      = -20:vox_size:20;
cfg.grid.unit       = 'cm';
cfg.grid.tight      = 'yes';
cfg.inwardshift   	= -1;               %  outward shift of the brain surface for inside/outside detection
cfg.headmodel      	= template_vol;
template_grid       = ft_prepare_sourcemodel(cfg);