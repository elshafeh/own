function  trans_index_H     = h_transform_voxel_inside(index_H)

load ../data/template/template_grid_0.5cm.mat

source_pos                  = [1:length(template_grid.pos)]';
source_pos                  = source_pos(template_grid.inside==1);

for nvox = 1:length(index_H)
    index_H(nvox,3) = find(source_pos == index_H(nvox,1));
end

trans_index_H = [index_H(:,3) index_H(:,2)];
