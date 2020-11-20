% first compute a big spatial filter ; let's say you're interested in
% post-cue effect from 300ms to 500ms from 8 to 12 HZ ; so make your filter
% bigger than your target period .. go for a filter from 100 to 700 , for
% example from 6 to 14 Hz

% load your data_elan file

load(data_elan_file);

% choose your period of interest

cfg             = [];
cfg.toilim      = [0.1 0.7]; % always in seconds
poi             = ft_redefinetrial(cfg, data_elan);

% Fourrier transform

cfg               = [];
cfg.method        = 'mtmfft';
cfg.foi           = 10; % put here your center frequency , in this example it's 10

cfg.tapsmofrq     = f_tap(t); % number of tapers here you want four tapers to make 10-4(6) and 10+4(14) .. the formula for the number you put is in this webpage
% http://www.fieldtriptoolbox.org/tutorial/timefrequencyanalysis#hanning_taper_fixed_window_length 
% fieldtrip will tell you how many tapers he'll use .. pay fuckin attention
% to that !!!

cfg.output        = 'powandcsd';
freq              = ft_freqanalysis(cfg,poi);

% now that you have your fourier , beam that shit , you need to load in
% your vol and leadfield

cfg                     = [];
cfg.method              = 'dics';
cfg.frequency           = freq.freq;
cfg.grid                = leadfield;
cfg.headmodel           = vol;
cfg.dics.fixedori       = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
cfg.dics.keepfilter     = 'yes'; % very very important
source                  = ft_sourceanalysis(cfg, freq);
com_filter              = source.avg.filter; % and this is your spatial filter buddy! 

