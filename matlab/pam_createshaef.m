clear ; clc ;
close all;

nparcel                         = 100;

dir_atlas                       = '~/github/CBIG/stable_projects/brain_parcellation/';
dir_atlas                       = [dir_atlas 'Schaefer2018_LocalGlobal/Parcellations/MNI/'];
atlas                           = ft_read_atlas([dir_atlas 'Schaefer2018_' num2str(nparcel) 'Parcels_17Networks_order_FSLMNI152_1mm.nii.gz']);

load ../data/stock/template_grid_0.1cm.mat
template_grid                   = ft_convert_units(template_grid,'mm');

source                          = [];
source.pos                      = template_grid.pos ;
source.dim                      = template_grid.dim ;
source.pow                      = zeros(length(source.pos),1);

cfg                             = [];
cfg.interpmethod                = 'nearest';
cfg.parameter                   = 'parcellation';
source_atlas                    = ft_sourceinterpolate(cfg, atlas, source);

vis_areas                       = find(contains(atlas.parcellationlabel,'Vis'));

mot_areas                       = find(contains(atlas.parcellationlabel,'SomMotA'));

aud_areas                       = find(contains(atlas.parcellationlabel,'SomMotB_S') | ...
    contains(atlas.parcellationlabel,'SomMotB_A'));

roi_interest                    = [mot_areas;aud_areas];

indx                            = [];

for d = 1:length(roi_interest)
    x                           =   find(ismember(atlas.parcellationlabel,atlas.parcellationlabel{roi_interest(d)}));
    indxH                       =   find(source_atlas.parcellation ==x);
    indx                        =   [indx ; indxH repmat(d,size(indxH,1),1)];
    clear indxH x
end

v1                              = find(source.pos(:,2) < -100);
indx                            = [indx; v1 repmat(13,length(v1),1)];

v2                              = find(source.pos(:,2) >= -100 & source.pos(:,2) < -90);
indx                            = [indx; v2 repmat(14,length(v2),1)];

v3                              = find(source.pos(:,2) >= -90 & source.pos(:,2) < -80);
indx                            = [indx; v3 repmat(15,length(v3),1)];

vox_pos                         = source.pos(indx(:,1),:);
indx(vox_pos(:,2) > -10,:)     	= [];

name_label                      = atlas.parcellationlabel(roi_interest)';

source                          = [];
source.pos                      = template_grid.pos ;
source.dim                      = template_grid.dim ;
source.inside                	= template_grid.inside ;
source.pow                      = nan(length(source.pos),1);

source.pow(indx(:,1))           = indx(:,2); %source.pos(indx(:,1),2); %

%%

cfg                             = [];
cfg.method                      = 'surface';
cfg.funparameter                = 'pow';
cfg.funcolormap                 = brewermap(16,'Spectral');
cfg.projmethod                  = 'nearest';
cfg.camlight                    = 'no';
cfg.surffile                    = 'surface_white_both.mat';
list_view                       = [-90 0 0 ; 90 0 0; 0 0 90; 0 -90 0];

for nview = [1 2]
    
    ft_sourceplot(cfg, source);
    view (list_view(nview,:));
    material dull
    title([num2str(nparcel) ' parcels']);
    
end

