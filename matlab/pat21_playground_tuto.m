% Granger Scenario 1

% To be able to compute spectrally resolved Granger causality,
% or other frequency-domain directional measures of connectivity, 
% we have to fit an autoregressive model to the data. 
% This is done using the ft_mvaranalysis function.

cfg         = [];
cfg.order   = 5;
cfg.toolbox = 'bsmart';
mdata       = ft_mvaranalysis(cfg, data);

% From the autoregressive coefficients it is now possible 
% to compute the spectral transfer matrix, for which we use ft_freqanalysis.

cfg        = [];
cfg.method = 'mvar';
mfreq      = ft_freqanalysis(cfg, mdata);

% Granger scenario 2

cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'dpss';
cfg.output    = 'fourier';
cfg.tapsmofrq = 2;
freq          = ft_freqanalysis(cfg, data);

% OR : 

cfg            = [];
cfg.output     = 'fourier';
cfg.method     = 'mtmfft';
cfg.foilim     = [5 100];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';
cfg.channel    = {'cortex' 'EMGlft' 'EMGrgt'};
freq    = ft_freqanalysis(cfg, combineddata);