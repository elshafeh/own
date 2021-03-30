clear ; clc ;

dir_field                       = '~/github/fieldtrip/template/atlas/aal/';
atlas                           = ft_read_atlas([dir_field 'ROI_MNI_V4.nii']);
atlas.tissuelabel               = atlas.tissuelabel';
atlas_param                     = 'tissue';

load ../data/stock/template_grid_0.5cm.mat

source                          = [];
source.pos                      = template_grid.pos ;
source.dim                      = template_grid.dim ;
source.pow                      = zeros(length(source.pos),1);

cfg                             = [];
cfg.interpmethod                = 'nearest';
cfg.parameter                   = atlas_param;
source_atlas                    = ft_sourceinterpolate(cfg, atlas, source);

% choose visual areas
vis_areas                       = [43:54];
% choose auditory areas
aud_areas                       = [79 80 81 82]; 
% choose motor areas
mot_areas                       = [1 2 57 58];

roi_interest                    = [mot_areas vis_areas aud_areas]; % 

indx                            = [];

for d = 1:length(roi_interest)
    
    if strcmp(atlas_param,'tissue')
        x                       =   find(ismember(atlas.tissuelabel,atlas.tissuelabel{roi_interest(d)}));
        indxH                   =   find(source_atlas.tissue==x);
        indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    else
        x                       =   find(ismember(atlas.brick1label,atlas.brick1label{roi_interest(d)}));
        indxH                   =   find(source_atlas.brick1==x);
        indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    end
    
    clear indxH x
    
end

name_label                      = atlas.tissuelabel(roi_interest)';

%% this is done to restrict the STG
supl                            = find(strcmp(name_label,'Temporal_Sup_L'));%[];%
supr                            = find(strcmp(name_label,'Temporal_Sup_R'));%[];%
adapt_vox                       = [indx source.pos(indx(:,1),:)];    

if ~isempty(supl)
    adapt_vox(adapt_vox(:,2) == supl & adapt_vox(:,4) > -2,:) = [];
    adapt_vox(adapt_vox(:,2) == supr & adapt_vox(:,4) > -2,:) = [];
end

indx                            = adapt_vox(:,1:2); clear adapt_vox;

%% this is done to restrict Heschl
supl                            = find(strcmp(name_label,'Heschl_L'));%[];%
supr                            = find(strcmp(name_label,'Heschl_R'));%[];%
adapt_vox                       = [indx source.pos(indx(:,1),:)];    

if ~isempty(supl)
    adapt_vox(adapt_vox(:,2) == supl & adapt_vox(:,4) > -2,:) = [];
    adapt_vox(adapt_vox(:,2) == supr & adapt_vox(:,4) > -2,:) = [];
end

indx                            = adapt_vox(:,1:2); clear adapt_vox;

%% this is done to restrict motor areas

prel                            = find(strcmp(name_label,'Precentral_L')); 
prer                            = find(strcmp(name_label,'Precentral_R')); 
posl                            = find(strcmp(name_label,'Postcentral_L')); 
posr                            = find(strcmp(name_label,'Postcentral_R'));

adapt_vox                       = [indx source.pos(indx(:,1),:)];    
focus_pos                       = 5;
limit_pos                       = 3.5;

if ~isempty(prel)
    adapt_vox(adapt_vox(:,2) == prel & adapt_vox(:,focus_pos) < limit_pos,:) = [];
    adapt_vox(adapt_vox(:,2) == prer & adapt_vox(:,focus_pos) < limit_pos,:) = [];
    adapt_vox(adapt_vox(:,2) == posl & adapt_vox(:,focus_pos) < limit_pos,:) = [];
    adapt_vox(adapt_vox(:,2) == posr & adapt_vox(:,focus_pos) < limit_pos,:) = [];
end

indx                            = adapt_vox(:,1:2); clear adapt_vox;

%%

roi_interest                    = unique(indx(:,2));

source                          = [];
source.pos                      = template_grid.pos ;
source.dim                      = template_grid.dim ;
source.inside                	= template_grid.inside ;
source.pow                      = nan(length(source.pos),1);

for nroi = 1:length(roi_interest)
    source.pow(indx(indx(:,2) == roi_interest(nroi),1)) = nroi*1;
end


cfg                             = [];
cfg.method                      = 'surface';
cfg.funparameter                = 'pow';
cfg.funcolormap                 = brewermap(12,'Spectral');
cfg.projmethod                  = 'nearest';
cfg.camlight                    = 'no';
cfg.surffile                    = 'surface_white_both.mat';
list_view                       = [-90 0 0 ; 90 0 0; 0 0 90; 0 -90 0];

for nview = [1 2]
    
    ft_sourceplot(cfg, source);
    view (list_view(nview,:));
    material dull
    
end