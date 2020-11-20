clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

load ../data/template/template_grid_0.5cm.mat

source.dim          = template_grid.dim;
source.pos          = template_grid.pos;
source.inside       = template_grid.inside;
source.pow          = ones(length(source.pos),1);

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
source_atlas        = ft_sourceinterpolate(cfg, atlas, source);

index_H             = [];
list_H              = {};
aha                 = 0;


for nroi = 1:length(atlas.tissuelabel)
    
    if strcmp(atlas.tissuelabel{nroi}(1:7),'Frontal')
        
        aha                         = aha + 1;
        
        x                           = find(ismember(atlas.tissuelabel,atlas.tissuelabel{nroi}));
        
        indxH                       = find(source_atlas.tissue==x);
        
        index_H                     = [index_H ; indxH repmat(aha,size(indxH,1),1)];
        
        list_H                      = [list_H atlas.tissuelabel{nroi}];
        
        clear indxH x
        
    end
    
end

clearvars -except index_H list_H;

save ../data/index/mni_frontal_rois_index.mat;