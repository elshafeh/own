clear;clc;

atlas           = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
reg_indx        = [1:20 23:26 31:36 43:54 57:70 79:90];
reg_list        = atlas.tissuelabel(reg_indx);

whrt = {};

for n = 1:length(atlas.tissuelabel)
    
    if ~strcmp(atlas.tissuelabel{n},reg_list)
        whrt{end+1,1} = atlas.tissuelabel{n};
    end
end