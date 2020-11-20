function [parcelfilt] = obob_svs_filt2parcel(cfg)
%
% function to calculate an average filter value for each parcel (in
% parcel_array) based on the grid_wise filters resulting from obob_svs_beamtrials_lcmvfilt 

% TO DO: add more options of merging filters, e.g. median, etc...

% cfg should contain
% cfg.parcel = an n-cell array (n=number of parcels) containing the individual parcels 
% cfg.filter = precomputed filters in obob_svs_beamtrials_lcmvfilt 

% Copyright (c) 2017 Anne Hauswald

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

parcel_array = cfg.parcel;
precmpfilter = cfg.filter.filter;
precmpnoise  = cfg.filter.noise;

parcel_filter = {};
parcel_noise = {};
parcel_parlabel = {};

for i = 1:length(parcel_array)
  parcelfilt_all  = precmpfilter(parcel_array{i}.roi_mask==1);
  parcelnoise_all = precmpnoise(parcel_array{i}.roi_mask==1);
  
  if ~isempty(parcelfilt_all)
    filt_dim  = ndims(parcelfilt_all{1});
    noise_dim = length(size(parcelnoise_all));

    temp_filt = cat(filt_dim+1, parcelfilt_all{:});
    temp_noise= cat(noise_dim, parcelnoise_all(:));

    filtmean  = (mean(temp_filt, filt_dim+1));
    noisemean = (mean(temp_noise, noise_dim+1));

    parcel_filter{end+1}   = filtmean;
    parcel_noise{end+1}    = noisemean;
    parcel_parlabel{end+1} = parcel_array{i}.roi_name;
  end %if
end

parcelfilt = [];
parcelfilt.filter   = parcel_filter;
parcelfilt.noise    = parcel_noise;
parcelfilt.parlabel = parcel_parlabel;
%%
end





%%