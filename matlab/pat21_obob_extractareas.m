function [ grid ] = obob_extractareas(cfg, grid)
% CIMEC_EXTRACTAREAS Use this function, to extract specific gridpoints
% (acccording to anatomical labels) from a labeled grid, created with
% obob_labeledgrid.
% 
% Use this function as:
%    grid = obob_extractareas(cfg, grid)
%
% Where grid is a labeled grid, created with obob_labeledgrid or a morphed
% grid created with obob_warpgrid.
%
% The configuration strucuture currently features the following options:
%
%   cfg.labels            = Labels to be extracted from the grid. This can
%                           either be a single string or a cell array of
%                           strings to extract multiple areas. If the
%                           labels in the grid do not specify the side of
%                           structure (i.e., left and right structures are
%                           named equally), you can add '@left' or '@right'
%                           to the label to extract only the left or right
%                           part of it. (Example: 'Brodmann area 41@left'
%                           only takes the left BA41). Please note that
%                           specifying cfg.side overrides individual side
%                           preferences.
%
%   cfg.side              = Only extract grid points on the specific
%                           hemisphere ('left' or 'right').

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
ft_defaults
ft_preamble provenance
ft_preamble trackconfig

% check config structure...
ft_checkconfig(cfg, 'required', 'labels');
cfg.side = ft_getopt(cfg, 'side', '');

if ischar(cfg.labels)
  if strcmp(cfg.labels, 'all')
    cfg.labels = keys(grid.label.name);
  else
    cfg.labels = {cfg.labels};
  end %if
end %if

% copy over grid...
orig_grid = grid;

% initialize new grid...
grid.pos = [];
grid.inside = [];
grid.outside = [];
if isfield(orig_grid, 'label')
  grid.label.name = containers.Map;
  grid.label.mni_pos = [];
end %if
if isfield(orig_grid, 'leadfield')
  grid.leadfield = {};
end %if
if isfield(orig_grid, 'orig_pos')
  grid.orig_pos = [];
end %if

% now we iterate over each given cfg.labels and put the gridpoints back in
% the structure...

% we need a store for all the grid points we already have in the new grid
% because some of the might appear more than once. we will save just the
% indices in the original grid in the variable...
grid_store = [];

for i=1:length(cfg.labels) 
  % get the idx of the corresponding grid points
  area = cfg.labels{i};
  cfg_tmp = [];
  cfg_tmp.labelstruct = orig_grid.label;
  cfg_tmp.labels = area;
  cfg_tmp.side = cfg.side;
  idx = obob_labelselection(cfg_tmp);
  
  % create label in new grid if necessary...
  if isfield(grid, 'label')
    grid.label.name(area) = [];
  end %if
  
  % check if we already have one of them inserted and delete those...
  [~, loc] = ismember(grid_store, idx);
  loc(loc == 0) = [];
  idx(loc) = [];
  
  % put the new indices into the grid store...
  grid_store = [grid_store idx];
  
  % and put the grid points into the grid...
  for i=1:length(idx)
    pos = orig_grid.pos(idx(i), :);
    pos_mni = orig_grid.label.mni_pos(idx(i), :);
    
    % put the gridpoint in the new grid...
    grid.pos(end+1, :) = pos;
    
    % check whether they are inside or outside the volume...
    if ismember(idx(i), orig_grid.inside)
      grid.inside(end+1) = size(grid.pos, 1);
    else
      grid.outside(end+1) = size(grid.pos, 1);
    end %if
    
    % readd missing extra fields...
    if isfield(grid, 'leadfield')
      grid.leadfield{end+1} = orig_grid.leadfield{idx(i)};
    end %if
    
    if isfield(grid, 'label')
      temp = grid.label.name(area);
      temp(end+1) = size(grid.pos, 1);
      grid.label.name(area) = temp;
      grid.label.mni_pos(end+1, :) = orig_grid.label.mni_pos(idx(i), :);
    end %if
  end %for
end %for


% cleanup
ft_postamble provenance
ft_postamble trackconfig


end

