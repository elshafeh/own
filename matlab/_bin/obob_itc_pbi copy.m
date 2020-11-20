function [phi, itcA, itcB, itc_all] = obob_itc_pbi(dataA, dataB, itc_all)

% obob_itc_pbi computes the inter-trial coherence (itc) and phase bifurcation index (pbi)
% of two conditions
%
% Use as:
%   [phi, itcA, itcB, itc_all] = obob_itc_pbi(dataA, dataB, itc_all)
%
% mandatory input:
%
% dataA   - first condition data, either fiedtrip structure containing
%           fourierspctrm field (output of ft_frequanalysis), or matrix
%           containing the itc for condition 1
% dataB   - second condition data, must match data1
%
% required input if dataA/B are itc:
%
% itc_all - itc of combinded dataset, needed only if dataA and dataB are
%           itc matricies, otherwise computed from the input data [default:
%           empty]
%
% output:
%
% phi     - phase bifurcation index
% itcA    - itc condition A
% itcB    - itc condition B
% itc_all - itc of combined data sets
%
% Ref:
% Busch, N. A., Dubois, J., & VanRullen, R. (2009). The phase of ongoing
%   EEG oscillations predicts visual perception. J Neurosci, 29(24),
%   7869–7876.

% Copyright (c) 2013-2016, Philipp Ruhnau
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

if isfield(dataA, 'fourierspctrm')
    disp('Input data contain fieldtrip structures including fourier spectra.')
    disp('Computing inter-trial coherence')
    disp(' ')
    % ITC
    % data 1
    dat = dataA.fourierspctrm;
    % normalize data in each trial
    dat = dat./abs(dat);
    % ITC is the length of the average complex numbers
    itcA = abs(mean(dat));
    
    % data 2
    dat = dataB.fourierspctrm;
    % normalize data in each trial
    dat = dat./abs(dat);
    % ITC is the length of the average complex numbers
    itcB = abs(mean(dat));
    
    % combined
    dat = [dataA.fourierspctrm; dataB.fourierspctrm];
    % normalize data in each trial
    dat = dat./abs(dat);
    % ITC is the length of the average complex numbers
    itc_all = abs(mean(dat, 1));
elseif isnumeric(dataA)&&isnumeric(dataB)&&isnumeric(itc_all)
    % report assumption
    disp('Input is inter-trial coherence')
    
    % and move to new vars
    itcA = dataA;
    itcB = dataB;    
else
    error('Wrong data input, See documentation')
end

% phase bifurcation index
phi = (itcA - itc_all) .* (itcB - itc_all);
% remove singlular (first) dimension
phi = squeeze(phi);