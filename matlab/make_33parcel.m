clear ; clc ;

vox_res               	= '0.5cm';

load(['../data/stock/template_grid_' vox_res '.mat']);

load ../data/stock/atlas_parcel333.mat
atlas.brick0label       = atlas.brick0label';

source               	= [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;

cfg                    	= [];
cfg.interpmethod     	= 'nearest';
cfg.parameter         	= 'brick0';
source_atlas           	= ft_sourceinterpolate(cfg, atlas, source);

roi_interest           	= [];

for nroi = 1:length(atlas.brick0label)
    
    answer = questdlg([atlas.brick0label{nroi} ' ?']);
    % Handle response
    switch answer
        case 'Yes'
            roi_interest           	= [roi_interest nroi];
        case 'No'
            disp('ok..')
    end  
end

index_vox           	= [];

for d = 1:length(roi_interest)
    
    indxH           	=   find(source_atlas.brick0==roi_interest(d));
    
    index_vox       	= [index_vox ; indxH repmat(roi_interest(d),length(indxH),1)];
    
    clear indxH x
    index_name{d}    	= atlas.brick0label{roi_interest(d)};
    clear indxH x
    
end

roi_interest            = unique(index_vox(:,2));

% for d = 1:length(roi_interest)

source.pow       	= nan(length(source.pos),1);
%     tmp              	= index_vox(index_vox(:,2) == roi_interest(d),1);

source.pow(index_vox(:,1)) = index_vox(:,2);

cfg                 = [];
cfg.method          = 'surface';
cfg.funparameter    = 'pow';
cfg.funcolormap     = 'jet';
cfg.projmethod      = 'nearest';
cfg.surfinflated    = 'surface_inflated_both_caret.mat';
cfg.camlight        = 'no';
% cfg.funcolorlim     = [0 17];
ft_sourceplot(cfg, source);
material dull

% end