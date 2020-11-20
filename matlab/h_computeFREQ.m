function freq = h_computeFREQ(suj,modality)

dir_data                            = ['../data/' suj '/preprocessed/'];
fname                               = [dir_data suj '_secondreject_postica_' modality '.mat'];
fprintf('loading %s \n',fname);
load(fname);

cfg                                 = [];
cfg.latency                         = [-0.5 0]; % this needs to be put in the filename
prestim_data                        = ft_selectdata(cfg, secondreject_postica); % select corresponding data

cfg                                 = [] ;
cfg.output                          = 'pow';
cfg.method                          = 'mtmfft';

cfg.keeptrials                      = 'yes';
cfg.pad                             = 3 ;
cfg.foi                             = 1:1/cfg.pad:25;
cfg.taper                           = 'hanning';
cfg.tapsmofrq                       = 0 ;
freq                                = ft_freqanalysis(cfg,prestim_data);

freq                                = rmfield(freq,'cfg');