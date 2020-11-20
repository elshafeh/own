function sfreq=obob_gm2_calcsource_fourier(cfg, freq, data)
% obob_gm2_calcsource_fourier projects the data in freq, obtained from
% obob_gm2_calcsen_fourier. The spatial filters are calculated separately
% using the data parameter.
%
% Use as
%   sfreq=obob_gm2_calcsource_fourier(cfg, freq, data)
%
% where the first input argument is a configuration structure (see below).
% The second argument is the output of obob_gm2_calcsens_fourier and will
% be projected to source space. The third argument contains single-trial
% time-domain data used to calculate the spatial filter.
%
% The configuration structure can contain:
%   cfg.grid       = The FieldTrip grid structure. Can have a precalculated
%                    leadfield.
%
%   cfg.vol        = The headmodel.
%
%   cfg.regfac     = The regularization factor (default = none).

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

%%
grid = cfg.grid;
vol = cfg.vol;

if isfield(cfg, 'regfac')
    regfac=cfg.regfac;
else
    regfac=[];
end

%%

if ~isfield(grid, 'leadfield')
if isfield(freq, 'grad')
    sens=freq.grad;
    sens=ft_convert_units(sens,'cm'); %force same units as grid and vol
    stype='grad';
elseif isfield(freq, 'elec')
    sens=freq.elec;
    sens=ft_convert_units(sens,'cm'); %force same units as grid and vol
    stype='elec';
end


cfg=[];
cfg.channel=freq.label;
cfg.grid = grid;
cfg.vol=vol;
cfg.(stype)=sens;

grid=ft_prepare_leadfield(cfg);
end %leadfield


%% check whether leadfield channel order and data sensor order match, if not abort for now
% get sensor indeces of data in lf and lf in data
[~, idA, idB] = intersect(data.label, grid.cfg.channel);
% compare order
lf_data_match = isequal(idA, idB);

if ~lf_data_match % if labels do not match try to find the reason and report
  
  if numel(data.label) ~= numel(grid.cfg.channel)
    error('The number of channels in your data and leadfield are different. Check whether cfg.channel contains the right input.')
  end
  % check if sorted leadfield labels would fit (likely ft_selectdata
  % problem)
  [~, idA, idB] = intersect(data.label, sort(grid.cfg.channel));
  lf_data_sort_match = isequal(idA, idB);
  if lf_data_sort_match
    error(['It seems your data sensors are ordered alphabetically. Try using obob_reorder_channels to undo this and submit again. '...
      'If the channel order in the data and in the leadfield don''t match the output of this function is wrong!'])
  else
    error('There is an unknown mismatch between your data sensors and the leadfield sensors')
  end
end

%%
sfreq=freq;

if isfield(freq, 'grad')
    sfreq=rmfield(freq, 'grad');
end

if isfield(freq, 'elec')
    sfreq=rmfield(freq, 'elec');
end

sfreq.label=cellstr(num2str([1:length(grid.inside)]'));
sfreq.fourierspctrm=zeros(size(freq.fourierspctrm,1),length(grid.inside), size(freq.fourierspctrm,3));

%%
for ff=1:length(freq.freq);

cfg=[];
cfg.method='mtmfft';
cfg.output='powandcsd';
cfg.foi=freq.freq(ff);
cfg.taper=freq.cfg.taper;
cfg.tapsmofrq=freq.cfg.tapsmofrq;
cfg.pad = freq.cfg.pad;

tmpfreq=ft_freqanalysis(cfg, data);

cfg=[];
cfg.channel=freq.label;
cfg.method='dics';
cfg.frequency=freq.freq(ff);
cfg.vol=vol;
cfg.grid=grid;
cfg.dics.lambda=regfac;
cfg.dics.keepfilter='yes';
cfg.dics.fixedori='yes';
cfg.dics.realfilter='yes';

tmp4filt=ft_sourceanalysis(cfg, tmpfreq);

idx_inside = find(tmp4filt.inside);

for ss=1:length(idx_inside)
    sfreq.fourierspctrm(:,ss,ff)=tmp4filt.avg.filter{idx_inside(ss)}*freq.fourierspctrm(:,:,ff)';
end
clear tmp*
end



