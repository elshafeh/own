clear ; clc ;

load(['../data/template/template_grid_0.5cm.mat']);

brainnetome                 = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii');
template_grid               = ft_convert_units(template_grid,brainnetome.unit);

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;
source.pow                  = nan(length(source.pos),1);

cfg                         = [];
cfg.interpmethod            = 'nearest'; % 'nearest', 'linear', 'cubic',  'spline', 'sphere_avg' or 'smudge'
cfg.parameter               = 'tissue';
source_atlas                = ft_sourceinterpolate(cfg, brainnetome, source);

roi_interest                = 1:length(brainnetome.tissuelabel);

index_vox                   = [];

for d = 1:length(brainnetome.tissuelabel)
    
    x                       =   find(ismember(brainnetome.tissuelabel,brainnetome.tissuelabel{d}));
    indxH                   =   find(source_atlas.tissue==x);
    index_vox               =   [index_vox ; indxH repmat(d,size(indxH,1),1)];
    clear indxH x

    index_name{d}           = brainnetome.tissuelabel{d};
    
    clear indxH x
    
end

keep index_*

save ../data/com_btomeroi.mat