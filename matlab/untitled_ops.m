clear;

dsFileName =  '~/Dropbox/project_ops/data/ds/sub01_localizer_left.ds';

cfg                             = [];
cfg.dataset                     = dsFileName;
cfg.trialfun                    = 'ft_trialfun_general';
cfg.trialdef.eventtype          = 'backpanel trigger';

cfg.trialdef.eventvalue         = [64];
cfg.trialdef.prestim            = 2;
cfg.trialdef.poststim           = 2;
cfg                         = ft_definetrial(cfg);

%%

cfg.channel               	= {'MEG'};
cfg.continuous            	= 'yes';
cfg.bsfilter             	= 'yes';
cfg.bsfreq               	= [49 51; 99 101; 149 151];
cfg.precision             	= 'single';
data                       	= ft_preprocessing(cfg);

% DownSample to 300Hz
cfg                      	= [];
cfg.resamplefs          	= 300;
cfg.detrend               	= 'no';
cfg.demean                	= 'no';
data_downsample          	= ft_resampledata(cfg, data); clear data;