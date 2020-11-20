function alpha = pad_alpha_allch(cfg,freq,s)
% find peak alpha freq
%
% use as:  alpha = pad_alpha(cfg,freq)
%
% required input:
%   freq        = output of ft_freqanalysis (see pad_fft & pad_cmb)
% required configuration parameters:
%   cfg.chansel = location of channel selection file
% optional configuration parameters:
%   cfg.method  = 'max', 'min', 'maxabs', 'maxreal' (default), or 'gaussian' or 'linear'
%   cfg.foi     = frequency range to be included in detection (default is [7 14] Hz)
%   cfg.fwidth  = range around the peak freq to take into account, (default is 1 Hz,
%                 which gives +/- 1 Hz centered at the peak freq

% copyright (c) 2018, saskia haegens

% set the defaults
if ~isfield(cfg, 'fwidth')
    cfg.fwidth = 1;
end
%%% note: further defaults set by alpha_peak

% load channel selection
load(cfg.chansel)
cfg.channel = [chansplan; chansmag];

% get alpha peak freq across chansel, across trials
alphapeak = alpha_peak(cfg, freq,s); % gives alpha peak freq & pow

% if no peak is found, then assign alphapeak to 10 Hz
% arbitrary value in the middle of the frequency range of interest
if isnan(alphapeak)
    alphapeak = 10;
end
%OR assign an arbitrary peak based on visual inspection of the FFT spectrum
if s == 12
    alphapeak = 8.5;
elseif s == 20
    alphapeak = 9.5;
end

% now get alpha power for this peak freq (+/- cfg.fwidth) per trial, for chansel
cfg.channel = 'all'
cfg.frequency  = [alphapeak(1)-cfg.fwidth alphapeak(1)+cfg.fwidth]; % foi: alpha peak freq +/- cfg.fwidth
cfg.keeptrials = 'yes'; % per individual trial
freq = ft_freqdescriptives(cfg,freq);
% now avg over chansel and foi
tmp = nanmean(freq.powspctrm,3);

% collect output: alpha [freq pow] per trial
alpha = zeros(size(freq.powspctrm,1),size(freq.powspctrm,2),2);
alpha(:,:,1) = alphapeak(1); % peak freq taken over avg, i.e., same for each trial
alpha(:,:,2) = tmp; % pow at this peak (+/- 1 hz) per trial
