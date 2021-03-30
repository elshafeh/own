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
aud_areas                       = [79 80 81 82]; %[85 86]; % 
% choose motor areas
mot_areas                       = [1 2 57 58];

roi_interest                    = [aud_areas]; % mot_areas vis_areas aud_areas

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

%% this is done to restrict auditory areas
% adapt_mid                       = [indx source.pos(indx(:,1),:)];
% mdl                             = find(strcmp(name_label,'Temporal_Mid_L'));
% mdr                             = find(strcmp(name_label,'Temporal_Mid_R'));
% if ~isempty(mdl)
%     adapt_mid(adapt_mid(:,2) == mdl & adapt_mid(:,4) > -4,:) = [];
%     adapt_mid(adapt_mid(:,2) == mdr & adapt_mid(:,4) > -4,:) = [];
% end
% indx                            = adapt_mid(:,1:2); clear adapt_mid;

%% this is done to restrict motor areas

prel                            = find(strcmp(name_label,'Precentral_L'));%[];%
prer                            = find(strcmp(name_label,'Precentral_R'));%[];%
posl                            = find(strcmp(name_label,'Postcentral_L'));%[];%
posr                            = find(strcmp(name_label,'Postcentral_R'));%[];%

adapt_mot                       = [indx source.pos(indx(:,1),:)];    
focus_pos                       = 5;
limit_pos                       = 4;

if ~isempty(prel)
    adapt_mot(adapt_mot(:,2) == prel & adapt_mot(:,focus_pos) < limit_pos,:) = [];
    adapt_mot(adapt_mot(:,2) == prer & adapt_mot(:,focus_pos) < limit_pos,:) = [];
    adapt_mot(adapt_mot(:,2) == posl & adapt_mot(:,focus_pos) < limit_pos,:) = [];
    adapt_mot(adapt_mot(:,2) == posr & adapt_mot(:,focus_pos) < limit_pos,:) = [];
end

indx                            = adapt_mot(:,1:2); clear adapt_mid;

%%

roi_interest                    = unique(indx(:,2));

source                          = [];
source.pos                      = template_grid.pos ;
source.dim                      = template_grid.dim ;
source.pow                      = nan(length(source.pos),1);

for nroi = 1:length(roi_interest)
    source.pow(indx(indx(:,2) == roi_interest(nroi),1)) = nroi*1;
end


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
    %     title(num2str(roi_interest));
    material dull
end