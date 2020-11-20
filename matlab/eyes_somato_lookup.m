clear;

left_pre        = load('P:/3015039.05/data/sub037/source/sub037_somatoleft.m240m0ms.lcmvsource.0.5cmWithNas.mat');
left_post       = load('P:/3015039.05/data/sub037/source/sub037_somatoleft.m0p240ms.lcmvsource.0.5cmWithNas.mat');
right_pre   	= load('P:/3015039.05/data/sub037/source/sub037_somatoright.m240m0ms.lcmvsource.0.5cmWithNas.mat');
right_post      = load('P:/3015039.05/data/sub037/source/sub037_somatoright.m0p240ms.lcmvsource.0.5cmWithNas.mat');

act_left        = (left_post.source - left_pre.source) ./ left_pre.source;
act_right       = (right_post.source - right_post.source) ./ right_pre.source;

load('../data/stock/template_grid_0.5cm.mat');

source          = [];

source.pos   	= template_grid.pos;
source.dim   	= template_grid.dim;
source.pow    	= (left_post.source - right_post.source) ./ (left_post.source + right_post.source);

cfg          	= [];
cfg.method   	= 'surface';
cfg.funparameter 	= 'pow';
% cfg.maskparameter  	= cfg.funparameter;
cfg.funcolorlim    	= [-0.1 0.1];
cfg.funcolormap                	= brewermap(256,'*RdBu');
cfg.projthresh      = 0.7;
cfg.projmethod                	= 'nearest';
cfg.camlight                   	= 'no';
cfg.surfinflated              	= 'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);
view([-90 0 0])
movegui('west')
ft_sourceplot(cfg, source);
view([90 0 0]);