clear ; clc ; 

atlas  = ft_read_atlas('../data_fieldtrip/Atlas_Schaefer2018/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_1mm.nii.gz');

load ../data_fieldtrip/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = zeros(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'brick0';
source_atlas            = ft_sourceinterpolate(cfg,atlas,source);

roi_interest            = [16:30 67:78];

indx = [];

for d = 1:length(roi_interest)
    
    x                       =   find(ismember(atlas.brick0label,atlas.brick0label{roi_interest(d)}));
    indxH                   =   find(source_atlas.brick0==x);
    indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    
    clear indxH x   
    
end

index_H        = indx;
list_H         = atlas.brick0label(roi_interest);

for n = 1:length(list_H)
    list_H{n} = list_H{n}(11:end);
end

% save('../data_fieldtrip/index/TD_BU_index.mat','index_H','list_H');

new_index               = [index_H(index_H(:,2) > 0 & index_H(:,2) < 8,:); index_H(index_H(:,2) > 15 & index_H(:,2) < 23,:)];

new_index               = [index_H(index_H(:,2) > 7 & index_H(:,2) < 15,:); index_H(index_H(:,2) > 22 & index_H(:,2) < 28,:)];


roi_to_plot             = unique(new_index(:,2));

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = nan(length(source.pos),1);

for nroi = 1:length(roi_to_plot)
    source.pow(new_index(new_index(:,2) == roi_to_plot(nroi),1)) = nroi*1;
end

z_lim                   = 20;


cfg                                         =   [];
cfg.method                                  =   'surface';
cfg.funparameter                            =   'pow';
cfg.funcolorlim                             =   [0 z_lim];
cfg.opacitylim                              =   [0 z_lim];
cfg.opacitymap                              =   'rampup';
cfg.colorbar                                =   'off';
cfg.camlight                                =   'no';
cfg.projmethod                              =   'nearest';
cfg.surffile                                =   'surface_white_both.mat';
cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);

