function alpha = prepare_bin(cfg, freq)

% sort trials based on (alpha) power
%
% settings for binning
%   cfg.foi     = choose freq range
%   cfg.channel = chans to include in sorting (default is 'all')
%   cfg.bin     = number of bins
% alternatively:
%   cfg.prc     = bin size (percentage)
%
% output contains the trial numbers in columns from low to high power
%
% copyright (c) 2013-2015, saskia haegens


% set defaults
if isfield(cfg, 'bin') && isfield(cfg, 'prc')
  error('specify either cfg.bin or cfg.prc, not both')
elseif isfield(cfg, 'prc')
  cfg.bin = 1/cfg.prc;
elseif isfield(cfg, 'bin')
  cfg.prc = 1/cfg.bin;
end
if ~isfield(cfg, 'output')
  cfg.output = 'all';
end
if ~isfield(cfg, 'channel')
  cfg.channel = 'all';
end
if strcmp(cfg.channel, 'all')
  cfg.channel = 1:length(freq.label);
end

if length(size(freq.powspctrm))>3 % input contains time dim
  freq.powspctrm = nanmean(freq.powspctrm,4); % avg over time
end

if length(cfg.channel)>1
  % normalize per chan (so that selection on alpha is not biased for high-power chans!!!)
  alpha=[];
  for i=1:length(freq.label)
    alpha(:,i,:) = freq.powspctrm(:,i,:)/nanmean(nanmean(freq.powspctrm(:,i,:)));
  end
else % this would apply to per layer binning
  alpha = freq.powspctrm;
end

alpha = alpha(:,cfg.channel,nearest(freq.freq,cfg.foi(1)):nearest(freq.freq,cfg.foi(2))); % all trials, laminar chans, foi
alpha = mean(mean(alpha,3),2);      % avg over freq, chans
alpha = [[1:length(alpha)]' alpha]; % add trial numbers
alpha = sortrows(alpha,2);          % sort based on alpha power
alpha = alpha(:,1);                 % only keep trial numbers

% create requested bins
nbins   = 1/cfg.prc;
binsize = floor(length(alpha)/nbins);
% now randomly remove some trials to avoid sampling bias
rest = rem(length(alpha),binsize);
rest = randperm(length(alpha),rest);
alpha(rest,:)=[];
for i=1:nbins
  tmp(:,i) = alpha(1+binsize*(i-1):binsize*i);
end

alpha = tmp;
