clear ; clc ; 

atlas = ft_read_atlas('/mnt/autofs/Aurelie/DATA/MEG/fieldtrip-20151124/template/atlas/spm_anatomy/AllAreas_v17.hdr');

atlas = ft_convert_units(atlas,'cm');

load ../data_fieldtrip/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = nan(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'brick0'; 
source_atlas            = ft_sourceinterpolate(cfg, atlas, source);

roi_interest            = 10:20 ; %1:length(atlas.brick0label);
indx = [];

for d = 1:length(roi_interest)
    
    x                       =   find(ismember(atlas.brick0label,atlas.brick0label{roi_interest(d)}));
    indxH                   =   find(source_atlas.brick0==x);
    indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    
end

for nroi = 1:length(unique(indx(:,2)))
   
    source.pow(indx(indx(:,2) == nroi,1)) = nroi;
    
end

z_lim                                       = 400;

cfg                                         =   [];
cfg.method                                  =   'surface';
cfg.funparameter                            =   'pow';
cfg.funcolorlim                             =   [0 z_lim];
cfg.opacitylim                              =   [0 z_lim];
cfg.opacitymap                              =   'rampup';
cfg.colorbar                                =   'off';
cfg.camlight                                =   'no';
cfg.projmethod                              =   'nearest';
cfg.surffile                                =   'surface_white_both.mat';
cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);
