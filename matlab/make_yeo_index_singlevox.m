clear ; clc ;

vox_res               	= '0.5cm';

load(['../data/stock/template_grid_' vox_res '.mat']);

yeo17                   = ft_read_atlas('H:\common\matlab\fieldtrip/template/atlas/yeo/Yeo2011_17Networks_MNI152_FreeSurferConformed1mm_LiberalMask_colin27.nii');
yeo17                   = ft_convert_units(yeo17,'cm');

source               	= [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;

cfg                    	= [];
cfg.interpmethod     	= 'nearest';
cfg.parameter         	= 'tissue';
source_atlas           	= ft_sourceinterpolate(cfg, yeo17, source);

roi_interest           	= 1:length(yeo17.tissuelabel);
index_vox           	= [];

for d = 1:length(roi_interest)
    
    indxH           	=   find(source_atlas.tissue==roi_interest(d));
    
    index_vox       	= [index_vox ; indxH repmat(roi_interest(d),length(indxH),1)];
    
    clear indxH x
    index_name{d}    	= yeo17.tissuelabel{roi_interest(d)};
    clear indxH x
    
end

keep index_* source template_*


roi_interest            = unique(index_vox(:,2));

for d = [14 15 16 17]
    
    source.pow       	= nan(length(source.pos),1);
    tmp              	= index_vox(index_vox(:,2) == roi_interest(d),1);
    
    source.pow(tmp)    	= d;
    
    cfg                 = [];
    cfg.method          = 'surface';
    cfg.funparameter    = 'pow';
    cfg.funcolormap     = 'jet';
    cfg.projmethod      = 'nearest';
    cfg.surfinflated    = 'surface_inflated_both_caret.mat';
    cfg.camlight        = 'no';
    cfg.funcolorlim     = [0 17];
    ft_sourceplot(cfg, source);
    material dull
    
end