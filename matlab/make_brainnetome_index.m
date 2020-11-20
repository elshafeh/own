clear ; clc ;

vox_res                     = '0.5cm';

load(['../data/template/template_grid_' vox_res '.mat']);

brainnetome                 = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii');
template_grid               = ft_convert_units(template_grid,brainnetome.unit);

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;
source.pow                  = nan(length(source.pos),1);

cfg                         = [];
cfg.interpmethod            = 'nearest';
cfg.parameter               = 'tissue';
source_atlas                = ft_sourceinterpolate(cfg, brainnetome, source);

roi_interest                = 1:length(brainnetome.tissuelabel);
roi_remove                  = [109:120 215:246];
roi_interest(roi_remove)    = [];

index_vox                   = [];

for d = 1:length(roi_interest)
    
    x                       =   find(ismember(brainnetome.tissuelabel,brainnetome.tissuelabel{roi_interest(d)}));
    indxH                   =   find(source_atlas.tissue==x);
    index_vox               =   [index_vox ; indxH repmat(d,size(indxH,1),1)];
    
    clear indxH x

    index_name{d}           = brainnetome.tissuelabel{roi_interest(d)};
    
    clear indxH x
    
end

save(['../data/template/brainnetome_roi' vox_res '.mat'],'index_vox','index_name','template_grid')