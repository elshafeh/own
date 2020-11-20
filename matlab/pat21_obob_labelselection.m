function [ idx ] = obob_labelselection( cfg )
%CIMEC_LABELSELECTION This function returns the indices of a voxels in a
%label hashmap generated with obob_labeledgrid.
%
% Use it as:
%    idx = obob_labelselection(cfg);
%
% with the following cfg options:
%
%   cfg.labelstruct                 = label structure from a grid or
%                                     leadfield (or wherever you got it
%                                     from...).
%
%   cfg.labels                      = Specify the labels here for wich you
%                                     want to extract the indices of its
%                                     gridpoints. You can specify one or
%                                     more labels in a cellstring array.
%                                     For example:
%                                     cfg.labels = 'Brodmann area 1' works
%                                     as well as:
%                                     cfg.labels = {'Brodmann area 1',
%                                     'Brodmann area 2', 'Brodmann area 3'}
%                                     If you want the indices of all
%                                     gridpoints associated with a label,
%                                     you can use cfg.labels = 'all'.
%                                     Finally, you can also choose which
%                                     hemisphere you want restrict to by
%                                     using cfg.labels = 'Brodmann area
%                                     1@left'. Please note that this gets
%                                     overridden when cfg.side is set.
%
%   cfg.side                        = Restrict the search to one
%                                     hemisphere. If you set this option,
%                                     it will override what you specified
%                                     in cfg.labels.

% Copyright (c) 2012-2016, Thomas Hartmann
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

% do some initialization...

% check cfg
ft_checkconfig(cfg, 'labelstruct', 'required');
ft_checkconfig(cfg, 'labels', 'required');

cfg.side = ft_getopt(cfg, 'side', '');

% check and adjust cfg.labels
if ischar(cfg.labels)
  if strcmp(cfg.labels, 'all')
    cfg.labels = keys(cfg.labelstruct.name);
  else
    cfg.labels = {cfg.labels};
  end %if
end %if

% initialize idx
idx = [];

for i=1:length(cfg.labels)
  % parse the label field.
  temp = textscan(cfg.labels{i}, '%s%s', 'Delimiter', '@');
  area = temp{1}{1};
  side = cfg.side;
  if isempty(side)
    if ~isempty(temp{2})
      side = temp{2}{1};
    else
      side = '';
    end %if
  end %if
  
  % get all indices...
  temp_idx = cfg.labelstruct.name(area);
  
  % check if we have to eleminate one hemisphere...
  if strcmp(side, 'left')
    temp_idx(cfg.labelstruct.mni_pos(temp_idx, 1) >= 0) = [];
  elseif strcmp(side, 'right')
    temp_idx(cfg.labelstruct.mni_pos(temp_idx, 1) <= 0) = [];
  end %if
  
  % add it to the list
  idx = [idx temp_idx];
end %if

% make list unique
idx = unique(idx);

end

