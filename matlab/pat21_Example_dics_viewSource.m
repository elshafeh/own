% load source activity and baseline 

% correct for baseline ; note that fieldtrip has no function dedicated for
% source baseline correction so you should use ft_math ;

cfg = [];
cfg.parameter = 'pow';
cfg.operation = '(x1-x2)./x2';
source_to_plot = f_math(cfg, source_activity,source_baseline);

source_interpolate  = h_interpolate(source_to_plot);

cfg                     = [];
cfg.method              = 'slice'; % check fieldtrip website for other options
cfg.funparameter        = 'pow';
cfg.nslices             = 16;
cfg.atlas               = atlas ;
ft_sourceplot(cfg,source_interpolate);

