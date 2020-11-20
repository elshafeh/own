clear ; clc ; 

load ../../fieldtrip-20151124/template/atlas/vtpm/vtpm.mat ;

vtpm = ft_convert_units(vtpm,'cm');

load ../data_fieldtrip/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = nan(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'tissue';
source_atlas            = ft_sourceinterpolate(cfg, vtpm, source);

roi_interest            = 1:length(vtpm.tissuelabel);

indx = [];

for d = 1:length(roi_interest)
    
    x                       =   find(ismember(vtpm.tissuelabel,vtpm.tissuelabel{roi_interest(d)}));
    
    for mb = 1:length(x)
        
        indxH                   =   find(source_atlas.tissue==x(mb));
        indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
        
    end
    
    clear indxH x
    
end

for nroi = 1:length(unique(indx(:,2)))
   
    source.pow(indx(indx(:,2) == nroi,1)) = nroi;
    
end

z_lim                                       = 100;

cfg                                         =   [];
cfg.method                                  =   'surface';
cfg.funparameter                            =   'pow';
cfg.projmethod                              = 'nearest';
cfg.funcolorlim                             =   [0 z_lim];
% cfg.opacitylim                              =   [0 z_lim];
% cfg.opacitymap                              =   'rampup';
cfg.colorbar                                =   'off';
cfg.camlight                                =   'no';
cfg.projmethod                              =   'nearest';
cfg.surffile                                =   'surface_white_both.mat';
cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);