clear ; clc ;

load ../data/yctot/stat/VNndt.lcmv.N1.mat

lst_side = {'left','right','both'};
lst_view = [-96 8;96 8;0 50];

% tmp{1} = stat ; clear stat ; stat = tmp ;

for cstat = 1
    for iside = 1:3
        
        source      = [];
        source.pos  = stat{cstat}.pos;
        source.dim  = stat{cstat}.dim;
        source.pow  = stat{cstat}.stat .* stat{cstat}.mask;
        
        cfg                     =   [];
        cfg.method              =   'surface';
        cfg.funparameter        =   'pow';
        cfg.funcolorlim         =   [-5 5];
        cfg.opacitylim          =   [-5 5];
        cfg.opacitymap          =   'rampup';
        cfg.colorbar            =   'off';
        cfg.camlight            =   'no';
        cfg.projthresh          =   0.1;
        cfg.projmethod          =   'nearest';
        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source);
        view(lst_view(iside,1),lst_view(iside,2))
        lst_cnd = {'N1'};
        saveFigure(gcf,['../../../../Desktop/VNnDT.N1.3dSource' '.' lst_side{iside} '.png']);
        %         close all;
        
    end
end
