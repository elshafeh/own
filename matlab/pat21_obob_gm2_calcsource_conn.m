function sconn=obob_gm2_calcsource_conn(cfg, sfreq)
% obob_gm2_calcsource_conn calculates the connectivity between all sources.
%
% This function uses the output of obob_gm2_calcsource_fourier to calculate
% the all-to-all connectivity between all sources.
%
% Use as
%  sconn=obob_gm2_calcsource_conn(cfg, sfreq)
%
% where the first input argument is a configuration structure (see below)
% and the second argument is a data structure obtained from
% obob_gm2_calcsource_fourier.
%
% The configuration structure can contain:
%   cfg.trials     = Which trials to use.
%
%   cfg.method     = One of the following methods to use: 'coh', 'icoh',
%                    'plv'

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
if isfield(cfg, 'trials')
    trs=cfg.trials;
else
    trs=(1:length(sfreq.cumsumcnt))';
end

%%
tmpcfg=[];
tmpcfg.trials=trs;

sfreq=ft_selectdata(tmpcfg, sfreq); clear tmp*

%%
switch cfg.method
    case 'coh'
        tmp=ft_checkdata(sfreq, 'cmbrepresentation', 'fullfast');

        cfg=[];
        cfg.method='coh';  
        sconn=ft_connectivityanalysis(cfg, tmp);
        clear tmp
    case 'icoh'
        tmp=ft_checkdata(sfreq, 'cmbrepresentation', 'fullfast');

        cfg=[];
        cfg.method='coh';
        cfg.complex='imag';
        sconn=ft_connectivityanalysis(cfg, tmp);
        clear tmp
    case 'plv'
        tmp=ft_checkdata(sfreq, 'cmbrepresentation', 'fullfast');

        cfg=[];
        cfg.method='plv';
        sconn=ft_connectivityanalysis(cfg, tmp);
        sconn.prob=exp(sqrt(1+4*n+4*(n^2-(n*sconn.plvspctrm).^2))-(1+2*n));
        clear tmp
end
        
