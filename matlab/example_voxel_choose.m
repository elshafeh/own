clear;

load ../data/stock/template_grid_0.5cm.mat

load ~/Desktop/sub004.6t8Hz.p180p1160.correct.fast.AlphaReconDics.mat;
source_activity     = source; clear source;

load ~/Desktop/sub004.6t8Hz.m1200m200.correct.slow.AlphaReconDics.mat;
source_baseline     = source; clear source;

% or try subtraction; whatever works
source_modulation   = (source_activity  - source_baseline) ./ source_baseline;

source              = [];
source.pow          = source_modulation;
source.pos          = template_grid.pos;

cfg                 = [];
cfg.hemisphere      = 'right';
cfg.number_voxels   = 2;
cfg.direction       = 'min';
[vox_list]          = h_findMaxVoxelPerRegion(source,cfg);

% always good to plot things to see how they look
% cfg                   = [];
% cfg.method            = 'surface';
% cfg.funparameter      = 'pow';
% cfg.maskparameter     = cfg.funparameter;
% cfg.funcolormap       = brewermap(256,'*RdBu');
% cfg.projmethod        = 'nearest';
% cfg.camlight          = 'no';
% cfg.surfinflated      = 'surface_inflated_both_caret.mat';
% cfg.projthresh        = 0.3;
% cfg.funcolorlim       = [-0.2 0.2];
% ft_sourceplot(cfg,source);
% material dull