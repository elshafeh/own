clear ; clc ; 

load(fname_in)      % load data file

% wavelet

cfg                 = [];
cfg.toi             = -1.5:0.05:1.5; % time window in steps if 50ms
cfg.method          = 'wavelet';
cfg.output          = 'pow';
cfg.foi             =  1:1:100; % frequency in steps of 1Hz
cfg.width           =  7 ; % elan's (m)
cfg.gwidth          =  4 ;
cfg.keeptrials      = 'no' ; % 'yes' for single trial analsyis 
cfg.trials          = h_chooseTrial(data_f,1,1,1:4); % choose trials 

% fourrier convol

cfg = [];
cfg.method            = 'mtmconvol';
cfg.taper             = 'hanning' ; % tapers
cfg.foi               = 5:18;
cfg.t_ftimwin         = 5./cfg.foi; % 5 cycles per frequency
cfg.toi               = -1.5:0.05:1.5; % time window in steps if 50ms
cfg.keeptrials        = 'no' ; % 'yes' for single trial analsyis 
cfg.trials            = h_chooseTrial(data_f,1,1,1:4); % choose trials 


freq                = ft_freqanalysis(cfg,data_elan);

%baseline correction

cfg = [];
cfg.baseline                = [-0.6 -0.2];
cfg.baselinetype            = 'relchange'; % check function for other options;
freq_bsl                    = ft_freqbaseline(cfg,freq);

% plot
ft_singleplotTFR(cfg,freq_bsl);
ft_multiplotTFR(cfg,freq_bsl);
ft_topoplotTFR(cfg,freq_bsl);