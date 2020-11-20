clear ; clc ;

atlas                           = ft_read_atlas('~/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
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

roi_interest                    = [];

[~, slct]                       = xlsread('~/Desktop/mni_select.xlsx');

for nroi = 1:length(slct)
    roi_interest                = [roi_interest;find(strcmp(atlas.tissuelabel,slct{nroi}))];
end

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
adapt_mid                       = [indx source.pos(indx(:,1),:)];

mdl                             = find(strcmp(name_label,'Temporal_Mid_L'));
mdr                             = find(strcmp(name_label,'Temporal_Mid_R'));

adapt_mid(adapt_mid(:,2) == mdl & adapt_mid(:,4) > -4,:) = [];
adapt_mid(adapt_mid(:,2) == mdr & adapt_mid(:,4) > -4,:) = [];

indx                            = adapt_mid(:,1:2); clear adapt_mid;

roi_interest                    = [15:18];%unique(indx(:,2));

source                          = [];
source.pos                      = template_grid.pos ;
source.dim                      = template_grid.dim ;
source.pow                      = nan(length(source.pos),1);

for nroi = 1:length(roi_interest)
    source.pow(indx(indx(:,2) == roi_interest(nroi),1)) = nroi*1;
end

z_lim                           = length(roi_interest);

cfg                             =   [];
cfg.method                      =   'surface';
cfg.funparameter                =   'pow';
cfg.funcolorlim                 =   [0 z_lim];
cfg.opacitylim                  =   [0 z_lim];
cfg.opacitymap                  =   'rampup';
cfg.colorbar                    =   'off';
cfg.camlight                    =   'no';
cfg.projmethod                  =   'nearest';
cfg.surffile                    =   'surface_white_both.mat';
cfg.surfinflated                =   'surface_inflated_both_caret.mat';
cfg.funcolormap                 = brewermap(256,'Reds');
ft_sourceplot(cfg, source);

index_vox                       = indx;
index_name                      = name_label;

keep index_*

save ../data/index/mnislct4bil.mat