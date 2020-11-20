function vox_index =h_find4NeighVoxels(center_vox)

load ../data_fieldtrip/template/template_grid_0.5cm.mat

center_pos              = template_grid.pos(center_vox,:);
stat_pos                = template_grid.pos;

vox_index               = [];

all_vox                 = [];
all_vox                 = [all_vox;center_pos];

all_vox                 = [all_vox ; center_pos + [-0.5 0 0 ]];
all_vox                 = [all_vox ; center_pos + [0.5 0 0]];
all_vox                 = [all_vox ; center_pos + [0 -0.5 0]];
all_vox                 = [all_vox ; center_pos + [0 0.5 0]];

for nvox = 1:length(all_vox)
    vox_index           = [vox_index ; find(stat_pos(:,1) == all_vox(nvox,1) & stat_pos(:,2) == all_vox(nvox,2) & stat_pos(:,3) == all_vox(nvox,3))];
end