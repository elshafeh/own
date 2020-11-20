clear ; clc ;

vox_res               	= '0.5cm';

load(['../data/template_grid_' vox_res '.mat']);

brainnetome          	= ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii');
template_grid         	= ft_convert_units(template_grid,brainnetome.unit);

source               	= [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow            	= nan(length(source.pos),1);

cfg                    	= [];
cfg.interpmethod     	= 'nearest';
cfg.parameter         	= 'tissue';
source_atlas           	= ft_sourceinterpolate(cfg, brainnetome, source);

roi_interest           	= 1:length(brainnetome.tissuelabel);
% roi_remove            	= [109:120 215:246];
% roi_interest(roi_remove)	= [];

index_vox           	= [];

for d = 1:length(roi_interest)
    
    x               	=   find(ismember(brainnetome.tissuelabel,brainnetome.tissuelabel{roi_interest(d)}));
    indxH           	=   find(source_atlas.tissue==x);
    
    allpos            	= source.pos(indxH,:);
    meanpos          	= mean(allpos);
    diffpos         	= [abs(allpos - meanpos) indxH];
    diffpos         	= sortrows(diffpos,[1 2 3]) ;
    
    slctpos          	= diffpos(1,4);
    
    
    index_vox       	=   [index_vox ; slctpos d];
    clear indxH x
    index_name{d}    	= brainnetome.tissuelabel{roi_interest(d)};
    clear indxH x
    
end

keep index_* template_grid

save ../data/brain1vox.mat

% keep source
% 
% source.pow(index_vox(:,1))       = index_vox(:,2);
% 
% cfg                     = [];
% cfg.method           	= 'surface';
% cfg.funparameter     	= 'pow';
% cfg.maskparameter      	= cfg.funparameter;
% cfg.funcolorlim      	= [0 length(index_name)];
% cfg.opacitymap        	= 'rampup';
% cfg.projmethod         	= 'nearest';
% cfg.camlight           	= 'no';
% cfg.surffile          	= 'surface_white_both.mat';
% cfg.surfinflated      	= 'surface_inflated_both.mat';
% 
% ft_sourceplot(cfg, source);