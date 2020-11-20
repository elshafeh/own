clear ;clc ;dleiftrip_addpath;

load ../data/template/source_struct_template_MNIpos.mat

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

indx_arsenal = h_createIndexfieldtrip(source);
indx_arsenal = indx_arsenal(indx_arsenal(:,2) < 91,:);
list_arsenal = atlas.tissuelabel(1:90);  clearvars -except indx_arsenal list_arsenal

save ../data/yctot/index/new_explor.mat ;