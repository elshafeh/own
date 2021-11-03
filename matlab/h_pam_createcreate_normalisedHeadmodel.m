function [vol, grid] = h_pam_createcreate_normalisedHeadmodel(mri_filename, template_grid_name)

% load MNI-fitted leadfield
load(template_grid_name)

fprintf('\nMake the individual subjects grid\n')

disp('Load MRI file')

% read the single subject anatomical MRI
mri                 = ft_read_mri(mri_filename);

fprintf('Segment the individual brain\n')

% segment the anatomical MRI

cfg                 = [];
cfg.downsample      = 1;
seg                 = ft_volumesegment(cfg, mri);

% %check segmented volume against mri
% mri.brainmask       = seg.gray+seg.white+seg.csf;
% cfg                 = [];
% cfg.interactive     = 'yes';
% cfg.funparameter    = 'brainmask';
% figure, hold on
% ft_sourceplot(cfg, mri);

% Comput leadfield(s)

% construct volume conductor model (i.e. head model) for each subject

fprintf('Construct a individual volume conduction model\nSingleshell method\n')
cfg                 = [];
cfg.method          = 'singleshell';
vol                 = ft_prepare_headmodel(cfg, seg);
vol                 = ft_convert_units(vol, 'cm');
vol.MNI_pos         = template_grid.pos;

fprintf('Create the individual specific grid, using the template grid\n')

cfg                 = [];
cfg.grid.warpmni    = 'yes';
cfg.grid.template   = template_grid;
cfg.grid.nonlinear  = 'yes'; % use non-linear normalization
cfg.mri             = mri;
grid                = ft_prepare_sourcemodel(cfg);

% Ici on ne construit que le model de source (o??? quelles sont les sources possibles ?). 
% Le leadfield (forward model) n'est pas encore
% calcul. C'est pourquoi les informations de positions des gradiom???tres
% n'ont aucune importance

grid.MNI_pos        = template_grid.pos;

% make a figure of the single subject headmodel, and grid positions

% figure, hold on
% ft_plot_vol(vol, 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
% ft_plot_mesh(grid.pos(template_grid.inside,:), 'vertexcolor', [0 0 0]);
% ft_plot_mesh(hdr.grad.chanpos);