clear ; close all;

load ../data/stock/template_grid_0.5cm.mat
load ../data/index/pam_broadmann.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = nan(length(source.pos),1);

list_roi                = [1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9];

for nroi = 1:length(index_name)
    
    flg                 = index_vox(index_vox(:,2) == nroi,1);
    source.pow(flg)     = list_roi(nroi);
    
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