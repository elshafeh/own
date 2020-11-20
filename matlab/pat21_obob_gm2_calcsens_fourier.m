function freq=obob_gm2_calcsens_fourier(cfg, data)
% obob_gm2_calcsens_fourier is a wrapper function to calculate the fourier
% coefficients in sensor space. The output will later be projected to
% source space by obob_gm2_calcsource_fourier.
%
% Use as
%   freq=obob_gm2_calcsens_fourier(cfg, data)
%
% where the first input argument is a configuration structure (see below)
% and the second argument is a preprocessing data structure containing single trials.
%
% The configuration structure can contain:
%   cfg.foi        = frequency vector
%
%   cfg.tapsmofreq = Frequency smoothing
%
%   cfg.taper      = The window function to use
%
%   cfg.pad        = The padding to use (default = 'maxperlen')

% Copyright (c) 2010-2016, The OBOB group
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

%
%Requires raw data from preproc struc
%
%INPUT:
%   -cfg.foi = frequency vector
%   -cfg.tapsmofreq = frequency smoothing (single number)

foi=cfg.foi;
tapsmofrq=cfg.tapsmofrq;
taper = cfg.taper;
pad = ft_getopt(cfg, 'pad', 'maxperlen');

%%
cfg=[];
cfg.method='mtmfft';
cfg.output='fourier';
cfg.foi=foi;
cfg.taper=taper; %IN CURRENT IMPLEMENTATION USE DPSS
cfg.tapsmofrq=tapsmofrq; %THIS WILL BE AUTOMATICALLY CHECKED FOR BEAMFORMER FILTER
cfg.pad = pad;

freq=ft_freqanalysis(cfg, data);