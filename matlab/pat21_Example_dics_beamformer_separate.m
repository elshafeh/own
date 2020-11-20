% you're interested in post-cue effect from 300ms to 500ms from 8 to 12 HZ and you created your common filter
% load your data_elan , leadfield , vol and the commonfilter

% choose your period of interest

cfg             = [];
cfg.toilim      = [0.3 0.5]; % always in seconds
poi             = ft_redefinetrial(cfg, data_elan);

% Fourrier transform

cfg               = [];
cfg.method        = 'mtmfft';
cfg.foi           = 10; % put here your center frequency , in this example it's 10

cfg.tapsmofrq     = f_tap(t); % number of tapers here you want four tapers to make 10-2(8) and 10+2(12) .. the formula for the number you put is in this webpage
% http://www.fieldtriptoolbox.org/tutorial/timefrequencyanalysis#hanning_taper_fixed_window_length 
% fieldtrip will tell you how many tapers he'll use .. pay fuckin attention
% to that !!!

cfg.output        = 'powandcsd';
freq              = ft_freqanalysis(cfg,poi);

cfg                     = [];
cfg.method              = 'dics';
cfg.frequency           = freq.freq;
cfg.grid                = leadfield;
cfg.headmodel           = vol;
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
cfg.grid.filter         = com_filter;
cfg.dics.fixedori       = 'yes';
source                  = ft_sourceanalysis(cfg, freq);