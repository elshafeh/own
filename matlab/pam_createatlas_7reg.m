clear; close all;

%load atlas and template MNI grid
load ../data/stock/template_grid_0.5cm.mat;
template_grid               = ft_convert_units(template_grid,'mm');

dir_field                   = '~/github/fieldtrip/template/atlas/yeo/';
yeo17                       = ft_read_atlas([dir_field 'Yeo2011_17Networks_MNI152_FreeSurferConformed1mm_LiberalMask_colin27.nii']);

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;
source.inside               = template_grid.inside;

cfg                         = [];
cfg.interpmethod            = 'nearest'; %'linear'; %
cfg.parameter               = 'tissue';
source_atlas                = ft_sourceinterpolate(cfg, yeo17, source);

% choose visual areas
vis_areas                   = [5 2 1];
% choose auditory areas
aud_areas                   = [4]; % 14 7 4
% choose motor areas
mot_areas                   = [3];

roi_interest                = [aud_areas]; % vis_areas aud_areas 

index_vox                   = [];

for d = 1:length(roi_interest)
    
    indxH                   = find(source_atlas.tissue==roi_interest(d));
    index_vox               = [index_vox ; indxH repmat(roi_interest(d),length(indxH),1)];
    
    clear indxH x
    index_name{d}           = ['yeo17 ' num2str(roi_interest(d))];% yeo17.tissuelabel{roi_interest(d)};
    clear indxH x
    
end

source.pow                  = nan(length(source.pos),1);
source.pow(index_vox(:,1))  = index_vox(:,2);

%%

cfg                         = [];
cfg.method                  = 'surface';
cfg.funparameter            = 'pow';
cfg.funcolormap             = brewermap(12,'Spectral');
cfg.projmethod              = 'nearest';
cfg.camlight                = 'no';
cfg.surffile                = 'surface_white_both.mat';
list_view                   = [-90 0 0 ; 90 0 0; 0 0 90; 0 -90 0];

for nview = [1 2]
    ft_sourceplot(cfg, source);
    view (list_view(nview,:));
    title(num2str(roi_interest));
    %         material dull
end