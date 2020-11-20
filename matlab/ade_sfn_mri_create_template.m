function [template_grid] = ade_sfn_mri_create_template(dir_fieldtrip,dir_out,vox_size)

global ft_default
ft_default.spmversion = 'spm12';

template_fname      = [dir_fieldtrip  'template/anatomy/single_subj_T1_1mm.nii'];
template            = ft_read_mri(template_fname);
template.coordsys   = 'spm';


fprintf('Segment the template brain\n')

% segment the template brain and construct a volume conduction model (i.e. head model)

cfg          = [];
template_seg = ft_volumesegment(cfg, template);

fprintf('Construct a template volume conduction model\nSingleshell method\n')
cfg          = [];
cfg.method   = 'singleshell';
template_vol = ft_prepare_headmodel(cfg, template_seg);
template_vol = ft_convert_units(template_vol, 'cm');

fprintf('Construct the dipole grid in the template brain\n')

% construct the dipole grid in the template brain coordinates the source units are in cm

cfg                     = [];
cfg.xgrid               = -20:vox_size:20;
cfg.ygrid               = -20:vox_size:20;
cfg.zgrid               = -20:vox_size:20;
cfg.unit                = 'cm';
cfg.tight               = 'yes';
cfg.inwardshift         = -1;               %  outward shift of the brain surface for inside/outside detection
cfg.headmodel           = template_vol;
template_grid           = ft_prepare_sourcemodel(cfg);

% % make a figure with the template head model and dipole grid

save([dir_out 'template_grid_' num2str(vox_size) 'cm.mat'],'template_grid');