function [region_index,region_name] = h_createIndexfieldtrip(vox_pos,atlas_path)

atlas                       = ft_read_atlas('~/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');

source                      = [];
source.pos                  = vox_pos;
source.pow                  = ones(length(source.pos),1);

cfg                         = [];
cfg.interpmethod            = 'nearest';
cfg.parameter               = 'tissue';
source_atlas                = ft_sourceinterpolate(cfg, atlas, source);

region_index = [];

for d = 1:length(atlas.tissuelabel)   
    x                       =   find(ismember(atlas.tissuelabel,atlas.tissuelabel{d}));
    indxH                   =   find(source_atlas.tissue==x);
    region_index        	=   [region_index ; indxH repmat(d,size(indxH,1),1)];
    clear indxH x   
end

region_name                 = atlas.tissuelabel';