clear ; clc ; dleiftrip_addpath ;

% compareGFP_CnD.m ;

load ../data/yctot/stat/CnD.CNV.lcmv.p600p1100.0p05.0p01.0p005.0p0005.mat ;

for cnd_s = 1:length(stat)
    [min_p(cnd_s),p_val{cnd_s}]     = h_pValSort(stat{cnd_s});
    stat{cnd_s}.mask                = stat{cnd_s}.prob < 0.05;
    reg_list{cnd_s}                 = FindSigClusters(stat{cnd_s},0.05);clc;
end

for iside = 1:3
    
    for cnd_s = 1:length(stat)
        
        stat{cnd_s}.mask            = stat{cnd_s}.prob < 0.05;
        source                      = [];
        source.pos                  = stat{cnd_s}.pos;
        source.dim                  = stat{cnd_s}.dim;
        source.pow                  = stat{cnd_s}.stat .* stat{cnd_s}.mask;
        source.pow(source.pow == 0) = NaN;
        
        lst_side = {'left','right','both'};
        lst_view = [-95 1;95,11;0 50];
        
        cfg                     =   [];
        cfg.method              =   'surface'; cfg.funparameter        =   'pow';
        cfg.funcolorlim         =   [-3 3]; cfg.opacitylim          =   [-3 3];
        cfg.opacitymap          =   'rampup';
        cfg.colorbar            =   'off'; cfg.camlight            =   'no';
        cfg.projthresh          =   0.2;
        cfg.projmethod          =   'nearest';
        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source);
        view(lst_view(iside,1),lst_view(iside,2))
    end
    
end