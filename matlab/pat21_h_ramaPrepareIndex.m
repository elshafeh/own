function [roi_list,vox_order,arsenal_list] = h_ramaPrepareIndex(big_ars_list)

load ../data/template/source_struct_template_MNIpos.mat

load(['../data/yctot/index/' big_ars_list '.mat'])

roi_list    = 1:size(final_rama_list,1);

vox_order   = 1:length(source.pos);
vox_order   = vox_order';
vox_order   = [vox_order source.inside] ;
vox_order   = vox_order(vox_order(:,2)==1,1); %

clear source ;

arsenal_list = final_rama_list;