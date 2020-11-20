clear; clc;dleiftrip_addpath;

load ~/Downloads/test_stat.mat

reg_list            = PlotSignificantVoxelsInAtlasRegion(stat,0.05);
region_of_interest  = 79;

slct_mask           = stat.mask(reg_list(reg_list(:,2) == region_of_interest,1));
slct_tval           = stat.stat(reg_list(reg_list(:,2) == region_of_interest,1));

source.pow          = zeros(length(stat.pos),1);
source.pow(reg_list(reg_list(:,2) == region_of_interest,1)) = slct_tval .* slct_mask;
source.dim          = stat.dim;
source.pos          = stat.pos;

z_lim               = 2;

for iside = 1
    
    lst_side                = {'left','right','both'};
    lst_view                = [-95 1;95,11;0 50];
    lst_position            = {[50 400 500 250],[700 400 500 250],[500 50 500 250]};
    
    cfg                     =   [];
    cfg.method              =   'surface';
    cfg.funparameter        =   'pow';
    cfg.funcolorlim         =   [-z_lim z_lim];
    cfg.opacitylim          =   [-z_lim z_lim];
    cfg.opacitymap          =   'rampup';
    cfg.colorbar            =   'off';
    cfg.camlight            =   'no';
    cfg.projthresh          =   0.2;
    cfg.projmethod          =   'nearest';
    cfg.surffile            =   'surface_white_left.mat';
    cfg.surfinflated        =   'surface_inflated_left.mat';
    ft_sourceplot(cfg, source);
    view(lst_view(iside,1),lst_view(iside,2))
    cfg                     = rmfield(cfg,'surfinflated');
    cfg.surffile            =   'surface_pial_left.mat';
    ft_sourceplot(cfg, source);
    view(lst_view(iside,1),lst_view(iside,2))
    %     set(gcf,'position',lst_position{iside})
end