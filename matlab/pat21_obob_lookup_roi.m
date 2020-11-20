function data = obob_lookup_roi(cfg, data)

% obob_lookup_roi creates a mask, an index, and a name field in your data for a specified
% region of interest (roi) extracted from an atlas
%
% Use as:
%   data = obob_lookup_roi(cfg, data)
%
% mandatory input:
% cfg.roi - cell of string(s), region(s) of interest (needs to be in the 
%           atlas)
% data    - source data structure (in fact, anything containing 3d mni or
%           tal positions, e.g., a grid structure)
%
% optional [defaults]:
% cfg.atlas      - filename of atlas or struct [TTatlas+tlrc.BRIK]
% cfg.inputcoord - coordinate system of input ['mni']
% 
% output:
% data - same as input but additional fields: 
% data.roi_mask - mask matrix, similar size to data
% data.roi_ind  - indizes of roi voxels (all positions, i.e. inside+oudside)
% data.roi_name - same as input cfg.roi

% Copyright (c) 2014-2016, Philipp Ruhnau
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


%% defaults
if ~isfield(cfg, 'roi'), error('If you want to look for a ROI then you should specify a ROI (cfg.roi empty)'); else roi = cfg.roi; end
atlas = ft_getopt(cfg, 'atlas', which('TTatlas+tlrc.BRIK')); 
coord = ft_getopt(cfg, 'inputcoord', 'mni'); 


cfg =[];

if ischar(atlas) % this can come in a later release, when ft is updated
     % read atlas
     cfg.atlas = ft_read_atlas(atlas);
else
    cfg.atlas = atlas;
end

% convert data to mm to fit atlas and keep original unit to backtransform
% later
orig_unit = ft_convert_units(data);
data = ft_convert_units(data, 'mm');

% convert atlas to mm just to be save
cfg.atlas = ft_convert_units(cfg.atlas, 'mm');

cfg.inputcoord = coord;
cfg.roi = roi;

% get a mask from volumelookup and put it into the data
data.roi_mask = ft_volumelookup(cfg, data);

% for some reason double needed for the mask, otherwise issue with 
% ft_checkdata, as long as not resolve keep like this (but delete later!)
data.roi_mask = double(data.roi_mask);

% get indices and name
data.roi_ind  = find(data.roi_mask==1);
data.roi_name = roi;

% convert data
data = ft_convert_units(data,orig_unit.unit);
