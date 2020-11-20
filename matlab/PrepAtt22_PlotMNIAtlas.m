clear ; clc ; 

atlas               = ft_read_atlas('../../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
load ../data_fieldtrip/template/template_grid_0.5cm.mat

source.pos          = template_grid.pos;
source.pow          = nan(length(source.pos),1);

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
source_atlas        = ft_sourceinterpolate(cfg, atlas, source);

excl;

big_list_H              = {};
big_index_H             = [];
nroi                = 0;

for d = 1:length(atlas.tissuelabel)   
    
    lkfor                               = find(strcmp(excludE_list,atlas.tissuelabel{d}));
    
    if isempty(lkfor)
        
        nroi                            = nroi +1;
        
        x                               =   find(ismember(atlas.tissuelabel,atlas.tissuelabel{d}));
        indxH                           =   find(source_atlas.tissue==x);
        big_index_H                     =   [big_index_H ; indxH repmat(nroi,size(indxH,1),1)];
        big_list_H                      =   [big_list_H; atlas.tissuelabel{d}];
        
        clear indxH x
        
    end
    
    
end

clearvars -except big_*;

load ../data_fieldtrip/index/broadmanAuditory_combined.mat

index_H(:,2)                    = index_H(:,2) + length(big_list_H);
big_list_H                      =   [big_list_H;list_H'];
big_index_H                     =   [big_index_H ; index_H];

list_H                          = big_list_H;
index_H                         = big_index_H;

clearvars -except index_H list_H;

save ../data_fieldtrip/index/MNIplusAudBroadman.mat;

% source.pow(index_H(:,1)) = index_H(:,2);
%
% cfg                                         =   [];
% cfg.method                                  =   'surface';
% cfg.funparameter                            =   'pow';
% cfg.funcolorlim                             =   [0 length(list_H)+10];
% cfg.opacitylim                              =   [0 length(list_H)+10];
% cfg.opacitymap                              =   'rampup';
% cfg.colorbar                                =   'off';
% cfg.camlight                                =   'no';
% cfg.projmethod                              =   'nearest';
% cfg.surffile                                =   'surface_white_both.mat';
% cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
% ft_sourceplot(cfg, source);