clear ; clc ;

roi_list = {'Precentral_L','Precentral_R','Supp_Motor_Area_L','Supp_Motor_Area_R'};

atlas           = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

load ../data/template/source_struct_template_MNIpos.mat
indxH = h_createIndexfieldtrip(source);

indx_tot = [];

for m = 1:length(roi_list)
    
    ix = find(strcmp(atlas.tissuelabel,roi_list{m}))
    
    %     indx_tot = [indx_tot ; indxH(indxH(:,2) == ix,:)];
    
end

% clearvars -except indx_tot roi_list
%
% save('../data/yctot/index/MotorArsenal.mat');