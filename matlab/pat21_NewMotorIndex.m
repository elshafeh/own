clear ; clc ;

load ../data/yctot/stat/source5mmBaselineStat.mat

roi_list = {'Precentral_L','Precentral_R','Supp_Motor_Area_L','Supp_Motor_Area_R'};
atlas    = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

indx_tot = [];

for roi = 1:4
    
    [vox_list,vox_indx] = h_findStatMaxVoxelPerRegion(stat{1,2},0.05,find(strcmp(atlas.tissuelabel,roi_list{roi})),5);
    
    indx_tot = [indx_tot ; vox_indx repmat(roi+300,length(vox_indx),1)];
    
    clear vox_list vox_indx
    
end

clearvars -except roi_list indx_tot

save ../data/yctot/index/NewMotorIndex.mat;