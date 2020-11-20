function indx = h_createIndexfieldtrip(source)

load ../data/template/source_struct_template_MNIpos.mat;

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

source              = rmfield(source,'freq');
source              = rmfield(source,'cumtapcnt');
source              = rmfield(source,'method');

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