clear; clc ;

load ../data/stat/prep21_conn_data.mat
load ../data/stat/prep22_gamma_pow.mat
load ../data/stat/prep22_gamma_con.mat

stat_alpha.mask             = (stat_alpha.prob < 0.05) .* 1;
stat_gamma_con.mask         = (stat_gamma_con.prob < 0.05) .* 2;
stat_gamma_pow.mask         = (stat_gamma_pow.prob < 0.05) .* 3;

common{1}                   = stat_alpha.mask .* stat_gamma_con.mask .* stat_gamma_pow.mask;
common{1}(common{1} ~=0)    = 7;

common{2}                   = stat_alpha.mask .* stat_gamma_con.mask ;
common{2}(common{2} ~=0)    = 4;

common{3}                   = stat_alpha.mask .* stat_gamma_pow.mask;
common{3}(common{3} ~=0)    = 5;

common{4}                   = stat_gamma_con.mask .* stat_gamma_pow.mask;
common{4}(common{4} ~=0)    = 6;

ncom                        = 4;
hihi                        = common{ncom};

source.pos                  = stat_alpha.pos;
source.dim                  = stat_alpha.dim;
source.pow                  = nan(length(stat_alpha.pos),1);

for n = 1:length(source.pow)
    
    if ncom == 2
        max_val                 = max([hihi(n,1) stat_alpha.mask(n,1) stat_gamma_con.mask(n,1)]);
    elseif ncom == 3
        max_val                 = max([hihi(n,1) stat_alpha.mask(n,1) stat_gamma_pow.mask(n,1)]);
    elseif ncom == 4
        max_val                 = max([hihi(n,1) stat_gamma_con.mask(n,1) stat_gamma_pow.mask(n,1)]);
    end
    
    if max_val ~= 0
        source.pow(n,1) = max_val;
    end
    
end

for iside = 1
    
    lst_side                = {'left','right','both'};
    lst_view                = [-125 13;95 11;0 50];
    
    z_lim                   = nanmax(source.pow)+1;
    
    cfg                     =   [];
    cfg.method              =   'surface';
    cfg.funparameter        =   'pow';
    cfg.funcolorlim         =   [0 z_lim];
    cfg.opacitylim          =   [0 z_lim];
    cfg.opacitymap          =   'rampup';
    cfg.colorbar            =   'off';
    cfg.camlight            =   'no';
    cfg.projmethod          =   'nearest';
    cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
    cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    cfg.funcolormap         = 'jet';

    ft_sourceplot(cfg, source);
    view(lst_view(iside,:))
    
end
