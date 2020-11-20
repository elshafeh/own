function [parcellation, template_grid] = obob_svs_create_parcellation(cfg)
% obob_svs_create_parcellation creates a parcellation structure to use with
% obob_svs_beamtrials_lcmv
%
% Please note that this function takes quite some time. For a 3mm version,
% it is sufficient to do:
%    load parcellations_3mm.mat
%
% Call as:
%    parcellation = obob_svs_create_parcellation(cfg);
%
% Input:
%    cfg.resolution     = The resolution of the grid in meters.
%
% Output:
%    The function returns a structure with the following fields:
%    template_grid   - The raw grid of the chosen resolution. Use this to
%                      warp it to the individual MR on which you need to
%                      calculate the leadfields
%    layout          - A layout that can be used to do ft_multiplot...
%    parcel_grid     - A grid structure with all the parcels. Use this in
%                      obob_svs_virtualsens2source.
%    parcel_array    - Information about the individual parcels. Used
%                      internally by obob_svs_beamtrials_lcmv

% Copyright (c) 2017, Anne Hauswald & Thomas Hartmann
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

this_cfg.resolution = ft_getopt(cfg, 'resolution', 3e-3);

load standard_bem
load standard_mri

% get root folder of obob_ownft...
[obob_ownft_root, ~, ~] = fileparts(which('obob_init_ft'));
data_folder = fullfile(obob_ownft_root, 'packages', 'svs', 'parcellation_data');

cfg = [];
cfg.grid.resolution = this_cfg.resolution;
cfg.grid.unit = 'm';
cfg.grid.tight = 'yes';
cfg.headmodel = vol;

template_grid = ft_prepare_sourcemodel(cfg);

% get labels
[tmp_labels, tmp_number, tmp_cent_x, tmp_cent_y, tmp_cent_z]=textread(fullfile(data_folder, 'Parcels_MNI_333_allinf.txt'), '%s %*s %d %*s %*f %f %f %f', 'headerlines',1);

for i = 1:length(tmp_labels)
  labels{i} = sprintf('%s_%d', tmp_labels{i}, tmp_number(i));
  centroids{i} = [tmp_cent_x(i), tmp_cent_y(i), tmp_cent_z(i)] .* 1e-3;
end %for

% load atlas
atlas = ft_read_atlas(fullfile(data_folder, 'Parcels_MNI_333.nii'));
atlas.brick0label=labels;% replace numered tissue by parcel labels
atlas.coordsys='mni';

% extract masks for parcels...
for i=1:length(labels)
  cfg = [];
  cfg.atlas = atlas;
  cfg.roi = labels{i}; % select rois
  cfg.inputcoord = 'mni';
  
  mask{i} = obob_lookup_roi(cfg,template_grid); %create one cell for each parcel containing a template_grid for this parcel
end

% create grid...
parcel_grid = rmfield(template_grid, {'inside', 'pos'});
for i = 1:length(labels)
  tmp_ind = dsearchn(template_grid.pos, centroids{i});
  parcel_grid.pos(i, :) = template_grid.pos(tmp_ind, :);
  parcel_grid.label{i} = labels{i};
end %for

parcel_grid.inside = true(length(labels), 1);

% create output...
parcellation.parcel_array = mask;
parcellation.parcel_grid = parcel_grid;
parcellation.parcel_grid = rmfield(parcellation.parcel_grid, {'xgrid', 'ygrid', 'zgrid', 'dim'});
parcellation.template_grid = template_grid;

% create layout...
cfg = [];
cfg.layout = parcellation.parcel_grid;
cfg.overlap='shift';
cfg.style='3d';

parcellation.layout = ft_prepare_layout(cfg);
parcellation.layout.pos = parcellation.layout.pos(:, 1:2);

end

