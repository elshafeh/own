clear ; clc ; close all;

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

% roi_interest                    = [];
% [~, slct]                       = xlsread('~/Desktop/mni_select.xlsx');
% for nroi = 1:length(slct)
%     roi_interest                = [roi_interest;find(strcmp(atlas.tissuelabel,slct{nroi}))];
% end

roi_interest                    = [1:2:90];
name_label                      = atlas.tissuelabel(roi_interest);

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

roi_interest                    = unique(indx(:,2));

for nroi = 1:length(roi_interest)
    
    source                          = [];
    source.pos                      = template_grid.pos ;
    source.dim                      = template_grid.dim ;
    source.pow                      = nan(length(source.pos),1);
    
    
    source.pow(indx(indx(:,2) == roi_interest(nroi),1)) = 1;
    
    z_lim                           = length(roi_interest);
    
    cfg                             =   [];
    cfg.method                      =   'surface';
    cfg.funparameter                =   'pow';
    cfg.funcolorlim                 =   [0 2];
    cfg.opacitylim                  =   [0 2];
    cfg.opacitymap                  =   'rampup';
    cfg.colorbar                    =   'off';
    cfg.camlight                    =   'no';
    cfg.projmethod                  =   'nearest';
    cfg.surffile                    =   'surface_white_both.mat';
    cfg.surfinflated                =   'surface_inflated_both_caret.mat';
    cfg.funcolormap                 = brewermap(256,'Reds');
    ft_sourceplot(cfg, source);
    title(name_label{nroi});
    
end