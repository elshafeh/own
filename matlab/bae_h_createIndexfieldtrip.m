function indx = h_createIndexfieldtrip(vox_pos,dir_fieldtrip)

atlas               = ft_read_atlas([dir_fieldtrip 'template/atlas/aal/ROI_MNI_V4.nii']);

source.pos          = vox_pos;
source.pow          = ones(length(source.pos),1);

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
source_atlas        = ft_sourceinterpolate(cfg, atlas, source);

indx = [];

for d = 1:length(atlas.tissuelabel)   
    x                       =   find(ismember(atlas.tissuelabel,atlas.tissuelabel{d}));
    indxH                   =   find(source_atlas.tissue==x);
    indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    clear indxH x   
end