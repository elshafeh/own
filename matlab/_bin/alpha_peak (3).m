function [alpha modfit] = alpha_peak(cfg, freq)

% detects the alpha peak freq and power at that freq
%
% use as:
% alpha = alpha_peak(cfg, freq)
% output alpha contains two values: [freq pow]
%  optional output: modfit for gaussian or linear fit
%
% input configuration:
%  cfg.method  = 'max', 'min', 'maxabs', 'maxreal' (default), or 'gaussian' or 'linear'
%  cfg.channel = channels to be included in detection (default is 'all')
%  cfg.foi     = frequency range to be included in detection (default is [7 14] Hz)

% copyright (c) 2013, saskia haegens

% updated 4/1/2019 to work with new ft_selectdata 

% set the defaults
if ~isfield(cfg, 'method')
  cfg.method = 'maxreal';
end
if ~isfield(cfg, 'channel')
  cfg.channel = 'all';
end
if ~isfield(cfg, 'foi')
  cfg.foi = [7 14];
end

% make sure full range included
if strcmp(cfg.method, 'maxreal')
  cfg.foi = cfg.foi+[-.1 .1]; % cause findpeaks skips the edges
end

% avg over potential rpt dimension
if strncmp('rpt', freq.dimord,3)
  freq = ft_freqdescriptives([],freq);
end
% avg over potential time dimension
if strcmp('time', freq.dimord(end-3:end))
  cfgsel=[];
  cfgsel.avgovertime = 'yes';
  cfgsel.nanmean     = 'yes';
  freq = data(cfgsel, freq);
  freq = rmfield(freq,'time');
  freq.dimord(end-4:end)=[];
end


% select relevant data
if ismember(cfg.method, {'gaussian', 'linear'})
    if length(freq.label) > 1
        cfgsel=[];
        cfgsel.channel     = cfg.channel;
        cfgsel.avgoverchan = 'yes';
        freq = ft_selectdata(cfgsel, freq);
    end
else
  cfgsel=[];
  cfgsel.channel     = cfg.channel;
  cfgsel.avgoverchan = 'yes';
  cfgsel.frequency   = cfg.foi;
  freq = ft_selectdata(cfgsel, freq);
end

% find alpha peak
alpha=[];
if strcmp(cfg.method, 'max')
  [alpha(2) alpha(1)] = max(freq.powspctrm);
elseif strcmp(cfg.method, 'min')
  [alpha(2) alpha(1)] = min(freq.powspctrm);
elseif strcmp(cfg.method, 'maxabs')
  [alpha(2) alpha(1)] = max(abs(freq.powspctrm));
  if max(freq.powspctrm)<abs(min(freq.powspctrm))
    alpha(2) = alpha(2) * -1;
  end
  
elseif strcmp(cfg.method, 'maxreal')
  [y x] = findpeaks(freq.powspctrm, 'sortstr', 'descend'); % find all (local) maxima
  if ~isempty(x)
    alpha = [x(1) y(1)]; % take the first (biggest) peak
  else % no peaks found
    alpha = [nan nan];
  end
  
  %%% LINEAR FIT %%% ~ beta ~
elseif strcmp(cfg.method, 'linear')
  freqin = freq;
  
  % linear fit
  x = find(freq.freq==cfg.foi(1)):find(freq.freq==cfg.foi(2));
  p = polyfit(freq.freq(x), freq.powspctrm(x), 1);
  modfit = p(1)*freq.freq + p(2);
  freq.powspctrm = freq.powspctrm - modfit; % subtract linear fit from spectrum
  
  % only keep the selected window (standard: 14-30 Hz ~excl~)
  cfgsel=[];
  cfgsel.frequency = cfg.foi;
  freq = ft_selectdata(cfgsel, freq);
  
  % find the peaks
  [y x] = findpeaks(freq.powspctrm, 'sortstr', 'descend'); % find all (local) maxima
  if ~isempty(x)
    if length(x)==1
      alpha = [freq.freq(x(1)) y(1)]; % take the only peak
    elseif y(1)*.7>y(2)
      alpha = [freq.freq(x(1)) y(1)]; % take the first (biggest) peak ~ if >30% than other peaks ~
    else % no true peak, series of bumps
      alpha = [nan nan];
    end
  else % no peaks found
    alpha = [nan nan];
  end
  % verify it's a true peak
  if ~isnan(alpha)
    tmp = freqin.powspctrm - modfit;
    % find lowest neighbouring points in a +/- 5 hz range)
    [min1] = min(tmp(nearest(freqin.freq,(alpha(1)-5)):nearest(freqin.freq,alpha(1))));
    [min2] = min(tmp(nearest(freqin.freq,alpha(1)):nearest(freqin.freq,(alpha(1)+5))));
    % if alpha peak is at least 30% higher, considered real peak
    if ~(alpha(2)*.7>min1 && alpha(2)*.7>min2)
      alpha = [nan nan];
    end
  end
  if ~isnan(alpha)
    alpha(2) = freqin.powspctrm(freqin.freq==alpha(1)); % get the orig power
  end
  
  %%% GAUSSIAN FIT %%% ~ alpha ~
elseif strcmp(cfg.method, 'gaussian')
  warning('this approach uses hardcoded parameter estimates, assuming alpha [7 14] Hz with mean of ~11 Hz')
  
  % get initial peak estimate
  cfgtmp=[];
  cfgtmp.method  = 'maxreal';
  alpha = alpha_peak(cfgtmp, freq);
  
  % start search around initial peak if there is one
  if ~isnan(alpha)
    foitmp = alpha(1);
  else
    foitmp = 11;
  end
  
  % locate the minima (i.e., the peak edges)
  [pks loc] = findpeaks(freq.powspctrm*-1);
  pks = pks*-1;
  % fix first peak? [ findpeaks skips borders ]
  if freq.powspctrm(1)<freq.powspctrm(2) && freq.powspctrm(1)<freq.powspctrm(nearest(freq.freq,foitmp))
    pks = [freq.powspctrm(1) pks];
    loc = [1 loc];
  end
  
  %%% adaptive approach %%%
  %%% use initial alpha peak if it was substantial enough (i.e, 10-20% increase compared to neighbours),
  %%% otherwise use closest local minimum around [9 13] range (i.e. assuming 11 hz peak),
  %%% or use standard range of [7 14] hz
  
  % find start of search window
  if pks(find(freq.freq(loc)<foitmp,1,'last'))<alpha(2)*.9 % threshold for alpha peak: 10%
    foi(1)=freq.freq(loc(find(freq.freq(loc)<foitmp,1,'last')));
  elseif any(freq.freq(loc)<=9) % alt: find local minimum
    foi(1)=freq.freq(loc(find(freq.freq(loc)<=9,1,'last')));
  else % backup
    foi(1)=7;
  end
  % remove start indices from search options
  pks(freq.freq(loc)<=foi(1))=[];
  loc(freq.freq(loc)<=foi(1))=[];
  
  % find end of search window
  if pks(find(freq.freq(loc)>foitmp,1,'first'))<alpha(2)*.8 % threshold for alpha peak: 20%
    foi(2)=freq.freq(loc(find(freq.freq(loc)>foitmp,1,'first')));
  elseif any(freq.freq(loc)>=13) % alt: find local minimum
    foi(2)=freq.freq(loc(find(freq.freq(loc)>=13,1,'first')));
  else % backup
    foi(2)=14;
  end
  
  % only keep the selected window (standard: 7-14 hz)
  freqin = freq;
  cfgsel=[];
  cfgsel.frequency = foi;
  freq = ft_selectdata(cfgsel, freq);  
  
  %%% GAUSSIAN FIT
  %%% this part is based on george's code
  
  % estimate parameters
  if ~isnan(alpha)
    mu          = alpha(1);
    sig         = 2;
    meanflat    = mean(freq.powspctrm);
    heightgauss = alpha(2); % ???
  else % > these give same performance actually..
    mu          = 11;
    sig         = 2;
    meanflat    = mean(freq.powspctrm); %.5; >mean is better
    heightgauss = 2;
  end
  paramguess = [mu sig meanflat heightgauss];
  
  lbounds = [7,0,0,0];
  ubounds = [14,inf,inf,inf];
  options = optimset('Display','off');
  params = fminsearchbnd(@fitgaussmin, paramguess, lbounds, ubounds, options, freq.powspctrm, freq.freq);
  
  % do the gaussian fit
  mu          = params(1);
  sigma       = params(2);
  meanflat    = params(3);
  heightgauss = params(4);
  modfit = meanflat.*ones(size(freq.freq)) + heightgauss.*normpdf(freq.freq,mu,sigma);
  %%% /george
  
  % get the alpha values
  alpha=[];
  [~, x] = max(modfit);
  xin = find(freqin.freq==freq.freq(x));
  if ~ismember(x,[1 length(freq.freq)]) && ~all(diff(round(modfit*1000))==0) &&...
      any(freqin.powspctrm(xin-30:xin-1)<freq.powspctrm(x)) && any(freqin.powspctrm(xin+1:xin+30)<freq.powspctrm(x))
    alpha(1) = freq.freq(x);
    alpha(2) = freq.powspctrm(x);
  else
    % no true peaks found [ flat line or no real gaussian fit ]
    alpha = [nan nan];
  end
  
  %%% do second attempt??!
  if isnan(alpha)
    % only keep the selected window - more restricted now
    foi = [7 14];
    cfgsel=[];
    cfgsel.frequency = foi;
    freq = ft_selectdata(cfgsel, freqin);
    
    % estimate parameters
    paramguess(3) = mean(freq.powspctrm);
    params = fminsearchbnd(@fitgaussmin, paramguess, lbounds, ubounds, options, freq.powspctrm, freq.freq);
    
    % do the gaussian fit
    mu          = params(1);
    sigma       = params(2);
    meanflat    = params(3);
    heightgauss = params(4);
    modfit = meanflat.*ones(size(freq.freq)) + heightgauss.*normpdf(freq.freq,mu,sigma);
    
    % get the alpha values
    alpha=[];
    [~, x] = max(modfit);
    xin = find(freqin.freq==freq.freq(x));
    if ~ismember(x,[1 length(freq.freq)]) && ~all(diff(round(modfit*1000))==0) &&...
        any(freqin.powspctrm(xin-30:xin-1)<freq.powspctrm(x)) && any(freqin.powspctrm(xin+1:xin+30)<freq.powspctrm(x))
      alpha(1) = freq.freq(x);
      alpha(2) = freq.powspctrm(x);
    else
      % no true peaks found [ flat line or no real gaussian fit ]
      alpha = [nan nan];
    end
  end
  %%% / second
  
  % also keep freq in the output
  modfit = [freq.freq; modfit];
end

% get the actual frequency
if ~ismember(cfg.method, {'gaussian', 'linear'}) && ~isnan(alpha(1))
  alpha(1) = freq.freq(alpha(1));
end
