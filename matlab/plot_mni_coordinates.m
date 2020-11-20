clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/stock/template_grid_0.5cm.mat

source               	= [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.inside           = template_grid.inside;

% % motor
% exclude_y               = find(source.pos(:,2) > 1 | source.pos(:,2) < -3);
% exclude_z               = find(source.pos(:,3) < 1);

% % visual
% exclude_y               = find(source.pos(:,2) > -6);
% exclude_z               = find(source.pos(:,3) > 3);

% % auditory
% exclude_y               = find(source.pos(:,2) > 0.1 | source.pos(:,2) < -4);
% exclude_z               = find(source.pos(:,3) < -1 | source.pos(:,3) > 2);

exclude                 = unique([exclude_y;exclude_z]);

% 1 is x-axis 2 is yaxis and 3 is z axis
source.pow              = source.pos(:,2);
source.pow(exclude)     = NaN;


cfg                     = [];
cfg.method              = 'surface';
cfg.funparameter        = 'pow';
cfg.funcolormap         = 'jet';
cfg.projmethod          = 'nearest';
cfg.surfinflated        = 'surface_inflated_both_caret.mat';
cfg.camlight            = 'no';
ft_sourceplot(cfg, source);
material dull
view([-90 0]);
movegui('east');

ft_sourceplot(cfg, source);
material dull
view([90 0]);
movegui('west');

% ft_sourceplot(cfg, source);
% material dull
% view([0 0]);
% movegui('north');
% 
% ft_sourceplot(cfg, source);
% material dull
% movegui('south');
