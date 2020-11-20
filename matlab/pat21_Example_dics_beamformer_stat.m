% You should create a cell array with rows = subjects and columns =
% conditions ; so if you have 14 subjects and 2 conditions you should end
% up with ann array called source_avg that has 14x2 dimensions

% note that each one your source has positions according to the subject's
% head .. this will fuck up your stat.. after loading each source you
% should change the source.pos to the mni positions which is found in your
% grid.MNI_pos

cfg                     =   [];
cfg.inputcoord          =   'mni';
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusteralpha        =   0.05;             % First Threshold
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.05;
cfg.tail                =   0;
cfg.clustertail         =   0;
nbsuj                   =   14; % number of subjects 
cfg.design(1,:)         =   [1:nbsuj 1:nbsuj];
cfg.design(2,:)         =   [ones(1,nbsuj) ones(1,nbsuj)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;

stat = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;

% now that you've made your stat let's look at the results
% this helps you get the facts about your clusters

[min_p,p_val]       = h_pValSort(stat);
list                = FindSigClusters(stat,0.2); % to know which areas are significant ; and how many voxels per areas

stat_int            = h_interpolate(stat);
stat_int.mask       = stat_int.prob < 0.05; % set up the mask
stat_int.stat       = stat_int.stat .* stat_int.mask;

cfg                         = [];
cfg.method                  = 'slice';
cfg.funparameter            = 'stat';
cfg.maskparameter           = 'mask';
cfg.nslices                 = 16;
cfg.funcolorlim             = [-5 5];
ft_sourceplot(cfg,stat_int);clc;