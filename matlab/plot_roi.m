clear ; clc ;

load ../../data/template/template_grid_0.5cm.mat
% load /Volumes/heshamshung/Fieldtripping6Dec2018/data/index/broadAudSchTPJMniPFC.mat
load ../../data/index/AudTPFC.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = nan(length(source.pos),1);

for nroi = 1:length(list_H)
    source.pow(index_H(index_H(:,2) == nroi,1),1) = nroi;
end

z_lim                      = length(list_H)+10;

for iside = 1:2
    
    lst_side               = {'left','right','both'};
    lst_view               = [-95 1;95 11;0 50];
    
    cfg                    =   [];
    cfg.method             =   'surface';
    cfg.funparameter       =   'pow';
    cfg.funcolorlim        =   [0 z_lim];
    cfg.opacitylim         =   [0 z_lim];
    cfg.opacitymap         =   'rampup';
    cfg.colorbar           =   'off';
    cfg.camlight           =   'no';
    cfg.projmethod         =   'nearest';
    
    cfg.surffile           =   ['surface_white_' lst_side{iside} '.mat'];
    cfg.surfinflated       =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    ft_sourceplot(cfg, source);
    view(lst_view(iside,:))

    
end