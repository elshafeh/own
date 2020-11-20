clear ; clc ;

fieldtrip_path                  = '/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/afni';
script_path                     = '/Users/heshamelshafei/Dropbox/project_me/meeg_compare/scripts';

% atlas                           = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/yeo/Yeo2011_17Networks_MNI152_FreeSurferConformed1mm_LiberalMask_colin27.nii');
% atlas_param                     = 'tissue';

atlas                           = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
atlas_param                     = 'tissue';

cd(script_path);

load ../data/template_grid_0.5cm.mat

source                          = [];
source.pos                      = template_grid.pos ;
source.dim                      = template_grid.dim ;
source.pow                      = zeros(length(source.pos),1);

cfg                             = [];
cfg.interpmethod                = 'nearest';
cfg.parameter                   = atlas_param;

source_atlas                    = ft_sourceinterpolate(cfg, atlas, source);

if strcmp(atlas_param,'tissue')
    roi_interest                = 1:90; % length(atlas.tissuelabel);
else
    roi_interest                = 1:length(atlas.brick1label);
end

index_vox                            = [];

for d = 1:length(roi_interest)
    
    if strcmp(atlas_param,'tissue')
        x                       =   find(ismember(atlas.tissuelabel,atlas.tissuelabel{roi_interest(d)}));
        indxH                   =   find(source_atlas.tissue==x);
        index_vox               =   [index_vox ; indxH repmat(d,size(indxH,1),1)];
    else
        x                       =   find(ismember(atlas.brick1label,atlas.brick1label{roi_interest(d)}));
        indxH                   =   find(source_atlas.brick1==x);
        index_vox               =   [index_vox ; indxH repmat(d,size(indxH,1),1)];
    end
    
    index_name{d}               = ['roi' num2str(d)];
    
    clear indxH x
    
end

keep index_* 

save ../data/com_90roi.mat