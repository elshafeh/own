function [vol, grid] = h_create_normalisedHeadmodel(mri_filename, template_file_name)

load(template_file_name);

% read the single subject anatomical MRI

load(mri_filename); % load in already preocessed MRIs

fprintf('Segment the individual brain\n')

%check segmented volume against mri
mri.brainmask       = seg.gray+seg.white+seg.csf;

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

grid.MNI_pos        = template_grid.pos;

% make a figure of the single subject headmodel, and grid positions
% figure, hold on
% ft_plot_vol(vol, 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
% ft_plot_mesh(grid.pos(template_grid.inside,:), 'vertexcolor', [0 0 0]);
% % ft_plot_mesh(hdr.grad.chanpos);