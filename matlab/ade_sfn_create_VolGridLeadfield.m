function ade_sfn_create_VolGridLeadfield(subjectName,modality)

% load in template
load('../misc_data/template_grid_0.5cm.mat');

% load in segmented mri

dir_data                = ['../data/' subjectName '/mri/'];
fname                   = [dir_data subjectName '_segmentMRI.mat'];
fprintf('loading %s \n',fname);
load(fname);

%check segmented volume against mri
mri.brainmask           = seg.gray+seg.white+seg.csf;

% Comput leadfield(s)
% construct volume conductor model (i.e. head model) for each subject

cfg                     = [];
cfg.method              = 'singleshell';
vol                     = ft_prepare_headmodel(cfg, seg);
vol                     = ft_convert_units(vol, 'cm');
vol.MNI_pos             = template_grid.pos;

cfg                     = [];
cfg.grid.warpmni        = 'yes';
cfg.grid.template       = template_grid;
cfg.grid.nonlinear      = 'yes'; % use non-linear normalization
cfg.mri                 = mri;
grid                    = ft_prepare_sourcemodel(cfg);

grid.MNI_pos            = template_grid.pos;

fname                   = [dir_data subjectName '_gridVol.mat'];
save(fname,'grid','vol','-v7.3');

fname                   = ['../data/' subjectName '/preprocessed/' subjectName '_secondreject_postica_' modality '.mat'];
fprintf('loading %s \n',fname);
load(fname);

cfg                     = [];
cfg.grid                = grid;
cfg.headmodel           = vol;
cfg.channel             = secondreject_postica.label;
cfg.grad                = secondreject_postica.grad;
leadfield               = ft_prepare_leadfield(cfg);

fname                   = [dir_data subjectName '_' modality '_leadfield.mat'];
fprintf('saving %s \n',fname);
save(fname,'leadfield','-v7.3');