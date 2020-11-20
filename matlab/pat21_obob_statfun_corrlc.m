function [s,cfg]=obob_statfun_corrlc(cfg, dat, design)
% bob_statfun_corrlc calculates (pearson) correlation coefficient between linear variable and
% circular data. This is a statfun and should not be called directly.
%
% Input:
%   dat      = Usually Fourier coefficients that will be converted into rad
%              internally.
%   design   = design matrix from ft_xxxstatistics call.
%              --> the linear variable (e.g. source power of ROI) should be on
%              the ivar row (e.g. in row one if cfg.ivar=1)
%
%   cfg.ivar = row number containing the independent variable
%
% Outputs structure s with following fields:
%   s.rho    = Correlation coefficient
%   s.prob   = p-value
%
% This function is an adapted (optimized) version of the circ_corrcl.m
% function of the erpac-toolbox (by Philipp Berens).
%
% References:
%     Biostatistical Analysis, J. H. Zar, p. 651

% Copyright (c) 2014-2016, Nathan Weisz
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

%%
% perform some checks on the configuration
%if strcmp(cfg.computecritval,'yes')
%  error('Computation of critical value (e.g. for clustering) not supported.');
%end;
%%

if ~isreal(dat)
  dat=angle(dat);
elseif isreal(dat) && max(abs(dat(:))) > pi
  error('obob_ownft:wrong_data', 'Invalid data provided. This statfun needs either fuorier coefficients or angle values (-pi : pi)');
end %if isreal

linvar=design(cfg.ivar,:); clear design

linvar=zscore(linvar);
linmat=repmat(linvar,size(dat,1),1);

df=size(dat,2)-1;

% compute correlation coefficent for sin and cos independently

rxs=sum(zscore(sin(dat)')'.*linmat,2)/df;
rxc=sum(zscore(cos(dat)')'.*linmat,2)/df;
rcs=sum(zscore(sin(dat)')'.*zscore(cos(dat)')',2)/df;

n = size(dat,2);

s=[];
% compute angular-linear correlation (equ. 27.47)
s.rho=sqrt((rxc.^2 + rxs.^2 - 2*rxc.*rxs.*rcs)./(1-rcs.^2));
% compute pvalue
s.prob = 1 - chi2cdf(n*s.rho.^2,2);

