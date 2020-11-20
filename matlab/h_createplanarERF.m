function localizer_timelock_planar_comb = h_createplanarERF(suj,modality)

dir_data                                   = ['../data/' suj '/preprocessed/'];
fname                                      = [dir_data suj '_secondreject_postica_' modality '.mat'];
fprintf('loading %s \n',fname);  
load(fname);

cfg                                        = [];
cfg.demean                                 = 'yes';
cfg.baselinewindow                         = [-0.2 0]; % baseline correction
cfg.lpfilter                               = 'yes'; % low pass filter
cfg.lpfreq                                 = 30;
dataFilt                                   = ft_preprocessing(cfg,secondreject_postica);

% selecting localizer data

localizer_trials                           = find(dataFilt.trialinfo(:,3) == 0);

cfg                                        = [];
cfg.channel                                = 'MEG';
cfg.trials                                 = localizer_trials;
localizer_data                             = ft_selectdata(cfg,dataFilt) ;

% ERF- Localizer
erf_localizer                              = ft_timelockanalysis([],localizer_data);

% Planar gradient
cfg                                        = [];
cfg.feedback                               = 'yes';
cfg.method                                 = 'template';
cfg.neighbours                             = ft_prepare_neighbours(cfg, erf_localizer);
close all ;

cfg.planarmethod                           = 'sincos';
localizer_timelock_planar                  = ft_megplanar(cfg, erf_localizer);

cfg                                        = [];
localizer_timelock_planar_comb             = ft_combineplanar(cfg,localizer_timelock_planar);

localizer_timelock_planar_comb              = rmfield(localizer_timelock_planar_comb,'cfg');