clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;
addpath('DrosteEffect-BrewerMap-b6a6efc/');

% load ../data/stat/prep22_gamma_pow.mat
% stat_gamma_pow.mask         = (stat_gamma_pow.prob < 0.05) .* 5;

load ../data/stat/prep21_conn_data.mat
load ../data/stat/prep22_gamma_con.mat

stat_alpha.mask             = (stat_alpha.prob < 0.05) .* 1;
stat_gamma_con.mask         = (stat_gamma_con.prob < 0.05) .* 2;

source.pos                  = stat_alpha.pos;
source.dim                  = stat_alpha.dim;
source.pow                  = nan(length(stat_alpha.pos),1);

for n = 1:length(source.pow)
    
    max_val                 = stat_alpha.mask(n,1) + stat_gamma_con.mask(n,1);

    if max_val ~= 0
        source.pow(n,1) = max_val;
    end
    
end

final_pow                       = source.pow;
final_pow(final_pow == 2)       = 30;
final_pow(final_pow == 3)       = 2;
final_pow(final_pow == 30)      = 3;

source.pow                      = final_pow;

for iside = 1
    
    lst_side                = {'left','right','both'};
    lst_view                = [-125 13;95 11;0 50];
    
    z_lim                   = nanmax(source.pow)+1;
    
    cfg                     =   [];
    cfg.method              =   'surface';
    cfg.funparameter        =   'pow';
    cfg.funcolorlim         =   [1 3];
    cfg.opacitylim          =   [1 3];
    cfg.opacitymap          =   'rampup';
    cfg.colorbar            =   'off';
    cfg.camlight            =   'no';
    cfg.projmethod          =   'nearest';
    cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
    cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    cfg.funcolormap         = 'jet';
    
    ft_sourceplot(cfg, source);
    view(lst_view(iside,:))
    
    %     colormap(brewermap(256, '*RdYlBu'));
    
end
