clear ;

atlas  = ft_read_atlas('../../fieldtrip-20151124/template/atlas/afni/TTatlas+tlrc.HEAD');

load ../data_fieldtrip/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = zeros(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'brick1';
source_atlas        = ft_sourceinterpolate(cfg, atlas, source);

indx = [];

for d = 1:length(atlas.brick1label)
    
    x                       =   find(ismember(atlas.brick1label,atlas.brick1label{d}));
    
    indxH                   =   find(source_atlas.brick1==x);
    
    indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    
    clear indxH x   
end

% source.pow(indx(indx(:,2) == 62 | indx(:,2) == 63,1)) = 5;

source.pow(indx(indx(:,2) == 39,1)) = 2;
source.pow(indx(indx(:,2) == 40,1)) = 5;
source.pow(indx(indx(:,2) == 41,1)) = 10;

lst_side                = {'left','right','both'};
lst_view                = [-95 1;95,11;0 50];

z_lim                   = 10;


cfg                                         =   [];
cfg.funcolormap                             = 'jet';
cfg.method                                  =   'surface';
cfg.funparameter                            =   'pow';
cfg.funcolorlim                             =   [0 z_lim];
cfg.opacitylim                              =   [0 z_lim];
cfg.opacitymap                              =   'rampup';
cfg.colorbar                                =   'off';
cfg.camlight                                =   'no';
cfg.projthresh                              =   0.2;
cfg.projmethod                              =   'nearest';
cfg.surffile                                =   'surface_white_both.mat';
cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);

