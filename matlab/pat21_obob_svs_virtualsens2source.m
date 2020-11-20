function source=obob_svs_virtualsens2source(cfg, virtualsens)

% A simple virtual sensor (svs)
% obob_svs_virtualsens2source takes on any gm structure with local graph theoretical parameter or
% any source time series (as created with svs_beamtrials_lcmv).
%
% Creates structure analogous to one following ft_sourceanalysis.
% Interpolation on MR optional.
%
% Call as:
% [source] = obob_svs_virtualsens2source(cfg, virtualsens)
%
% INPUT:
%  virtsens           = timelock/freq/timefreq struct in source space
%  cfg.sourcegrid     = source grid
%  cfg.parameter      = local graph theoretical parameter you want in source
%                       space
%  cfg.frequency      = freqency range
%  cfg.latency        = time range
%  cfg.mri            = (OPTIONAL) mri corresponding to sourcegrid; this 
%                       option will automatically output a interpolated 
%                       struc!
%  cfg.nanmean        = (OPTIONAL)if true, the function will use nanmean instead of
%                       the default mean function for averaging. (default =
%                       false.)
%  cfg.downsample     = (OPTIONAL) If an mri is provided this is the level
%                       of downsampling that will be inputed into 
%                       ft_sourceinterpolate (deafult = 1)
% Output:
% source - struct similar to output of ft_sourceanalysis

% Copyright (c) 2014-2016, Nathan Weisz, Philipp Ruhnau & Thomas Hartmann
%
% This file is part of the obob_ownft distribution, see: https://gitlab.com/obob/obob_ownft/
%
%    obob_ownft is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    obob_ownft is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with obob_ownft. If not, see <http://www.gnu.org/licenses/>.
%
%    Please be aware that we can only offer support to people inside the
%    department of psychophysiology of the university of Salzburg and
%    associates.

% grid
ft_checkconfig(cfg, 'sourcegrid', 'required');
ft_checkconfig(cfg, 'parameter', 'required');

% set defaults
cfg.nanmean = ft_getopt(cfg, 'nanmean', 0);
cfg.downsample = ft_getopt(cfg, 'downsample', 1);

% check backward names
cfg = ft_checkconfig(cfg, 'renamed', {'toilim' 'latency'});
cfg = ft_checkconfig(cfg, 'renamed', {'foilim' 'frequency'});

sgrid=cfg.sourcegrid;

% check for an mri
if isfield(cfg, 'mri')
  mri=cfg.mri;
  sinter=1;
  sdown = cfg.downsample;
else
  sinter=0;
end %if

% selected parameter(s)
if ~iscell(cfg.parameter) % make cell if string
  interparam = {cfg.parameter};
else
  interparam = cfg.parameter;
end %if

if cfg.nanmean
  meanfunc = @nanmean;
else
  meanfunc = @mean;
end %if

% select the data indeces
if strcmpi(virtualsens.dimord,'chan_time') % timelock
  ftype=1;
  toilim = cfg.latency;
  t1 = nearest(virtualsens.time, toilim(1));
  t2 = nearest(virtualsens.time, toilim(2));
elseif strcmpi(virtualsens.dimord,'chan_freq') % freq
  ftype=2;
  foilim = cfg.frequency;
  f1 = nearest(virtualsens.freq, foilim(1));
  f2 = nearest(virtualsens.freq, foilim(2));
elseif strcmpi(virtualsens.dimord,'chan_freq_time') % channel x frequency x time
  ftype=3;
  foilim = cfg.frequency;
  f1 = nearest(virtualsens.freq, foilim(1));
  f2 = nearest(virtualsens.freq, foilim(2));
  toilim = cfg.latency;
  t1 = nearest(virtualsens.time, toilim(1));
  t2 = nearest(virtualsens.time, toilim(2));
else % asuming there is only one dimension
  ftype = 0;
end %if

%% check whether selected time range is within data limits
if ismember(ftype, [1 3]) % check for time and time-freq only  
  % the [min max] range can be specifed with +inf or -inf, but should
  % at least partially overlap with the time axis of the input data
  mintime = min(virtualsens.time);
  maxtime = max(virtualsens.time);
  if all(toilim<mintime) || all(toilim>maxtime)
    error('the selected time range falls outside the time axis in the data');
  end
end

%% check whether selected freq range is within data limits
if ismember(ftype, [2 3]) % check for freq and time-freq only  
  % the [min max] range can be specifed with +inf or -inf, but should
  % at least partially overlap with the freq axis of the input data
  minfreq = min(virtualsens.freq);
  maxfreq = max(virtualsens.freq);
  if all(foilim<minfreq) || all(foilim>maxfreq)
    error('the selected frequency range falls outside the frequency axis in the data');
  end %if
end %if

%% prepare source structure
source=sgrid;
for iPar = 1:numel(interparam)
  
  % select current parameter
  cur_param = interparam{iPar};
  
  % compute mean across selected dimensions (time/freq)
  if ftype == 0
    tmp = virtualsens.(cur_param);
  elseif ftype == 1
    tmp=meanfunc(virtualsens.(cur_param)(:, t1:t2),2);
  elseif ftype == 2
    tmp=meanfunc(virtualsens.(cur_param)(:, f1:f2),2); %add other freq options
  elseif ftype == 3
    tmp=meanfunc(meanfunc(virtualsens.(cur_param)(:, f1:f2, t1:t2),2),3);
  end %if
  
  % create field in source style
  source.(cur_param)=NaN(size(source.pos,1),1);
  source.(cur_param)(source.inside)=tmp;
  
  clear tmp
end %for

%% interpolate if needed

if sinter == 1
  cfg=[];
  cfg.parameter=interparam;
  cfg.downsample = sdown;
  source = ft_sourceinterpolate(cfg, source, mri);
  
  if isfield(mri, 'gray') && isfield(mri, 'white')
    source.brain_mask = mri.gray | mri.white;
  end %if
  
  if isfield(mri, 'brain')
    source.brain_mask = mri.brain;
  end %if
end %if