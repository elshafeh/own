function [roi_numerical_list,vox_order,voxel_index_plus_name] = h_ramaPrepareIndex(index_file_name)

load ../data_fieldtrip/template/template_grid_0.5cm.mat

% load ../data_fieldtrip/index/NewSourceAudVisMotor.mat
% load ../data_fieldtrip/index/allyoungcontrol_p600p1000lowAlpha_bsl_contrast_select.mat
% roi_list    = 1:size(rama_list,1);
% clear source ;
% voxel_index = list_arsenal;

load(index_file_name);

% index_H                 = [index_H(:,1) index_H(:,4)];

vox_order               = 1:length(template_grid.pos);
vox_order               = vox_order';
vox_order               = [vox_order template_grid.inside] ;
vox_order               = vox_order(vox_order(:,2)==1,1);

roi_numerical_list      = 1:length(list_H);

for nroi = 1:length(roi_numerical_list)
   
    voxel_index_plus_name{nroi,1} = list_H{roi_numerical_list(nroi)};
    voxel_index_plus_name{nroi,2} = index_H(index_H(:,2)==roi_numerical_list(nroi),1);
    
end