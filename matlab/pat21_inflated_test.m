cfg                     =   [];
cfg.method              =   'surface';
cfg.funparameter        =   'pow';
cfg.funcolorlim         =   [-4 4];
cfg.opacitylim          =   [-4 4];
cfg.opacitymap          =   'rampup';
cfg.colorbar            =   'off';
cfg.camlight            =   'no';
cfg.projthresh          =   0.2;
cfg.projmethod          =   'nearest';
cfg.surffile            =   'surface_white_both.mat';
cfg.surfinflated        =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source); % wokrs without interpolating , i think..