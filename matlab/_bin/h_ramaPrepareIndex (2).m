function [roi_numerical_list,vox_order,voxel_index_plus_name] = h_ramaPrepareIndex(index_file_name,template_file_name)

load(template_file_name)
load(index_file_name);

vox_order               = 1:length(template_grid.pos);
vox_order               = vox_order';
vox_order               = [vox_order template_grid.inside] ;
vox_order               = vox_order(vox_order(:,2)==1,1);

roi_numerical_list      = 1:length(index_name);

for nroi = 1:length(roi_numerical_list)
   
    voxel_index_plus_name{nroi,1} = index_name{roi_numerical_list(nroi)};
    voxel_index_plus_name{nroi,2} = index_vox(index_vox(:,2)==roi_numerical_list(nroi),1);
    
end