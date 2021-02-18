clear;

name_in                         = '/Users/heshamelshafei/Downloads/sub019_secondreject_postica_vis.mat';
load(name_in);

% DownSample
cfg                             = [];
cfg.resamplefs                  = 100;
cfg.detrend                     = 'no';
cfg.demean                      = 'no';
data                            = ft_resampledata(cfg, secondreject_postica);
data                            = rmfield(data,'cfg');

name_out                      	= '/Users/heshamelshafei/Downloads/data_downsample.mat';
save(name_out,'data','-v7.3');
