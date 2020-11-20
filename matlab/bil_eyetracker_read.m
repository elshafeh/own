keep ds_name

cfg                             = [];
cfg.dataset                     = ds_name;
cfg.trialfun                    = 'ft_trialfun_general';
cfg.trialdef.eventtype          = 'UPPT001';
cfg.continuous                  = 'yes';
cfg.precision                   = 'single';
cfg.channel                     = {'UADC006','UADC007','UADC008'};

cfg.trialdef.eventvalue         = [11 12 13];
cfg.trialdef.prestim            = 1;
cfg.trialdef.poststim           = 7;
cfg                             = ft_definetrial(cfg);

eye_track                     	= ft_preprocessing(cfg);