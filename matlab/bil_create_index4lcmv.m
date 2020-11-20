clear ; clc ;

atlas                           = ft_read_atlas('H:\common\matlab\fieldtrip\template\atlas\aal\ROI_MNI_V4.nii');
atlas_param                     = 'tissue';

load ../data/stock/template_grid_0.5cm.mat

source                          = [];
source.pos                      = template_grid.pos ;
source.dim                      = template_grid.dim ;
source.pow                      = zeros(length(source.pos),1);

cfg                             = [];
cfg.interpmethod                = 'nearest';
cfg.parameter                   = atlas_param;

source_atlas                    = ft_sourceinterpolate(cfg, atlas, source);
roi_interest                    = [1:16 19:20 23:26 31:36 43:70 79:90];

indx                            = [];

for d = 1:length(roi_interest)
    
    x                           =   find(ismember(atlas.tissuelabel,atlas.tissuelabel{roi_interest(d)}));
    indxH                       =   find(source_atlas.tissue==x);
    indx                        =   [indx ; indxH repmat(d,size(indxH,1),1)];
    
    clear indxH x
    
end

mni_label                       = atlas.tissuelabel(roi_interest);
mni_index                       = indx; 

keep mni_*

save ../data/index/mni_index4bil.mat