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
source_atlas            = ft_sourceinterpolate(cfg, atlas, source);

indx = [];

for d = 1:length(atlas.brick1label)
    
    x                       =   find(ismember(atlas.brick1label,atlas.brick1label{d}));
    
    indxH                   =   find(source_atlas.brick1==x);
    
    indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    
    clear indxH x   
end

index_H = [indx(indx(:,2) == 30 ,:) ; indx(indx(:,2) == 32 ,:)];  

index_H(index_H(:,2) == 30,2) = 1;
index_H(index_H(:,2) == 32,2) = 2;

for n = 1:length(index_H)
    if source.pos(index_H(n,1),1) < 0
        index_H(n,3) = 1;
    else
        index_H(n,3) = 2;
    end
end

index_H(:,4) = 0;

index_H(index_H(:,2) == 1 & index_H(:,3) == 1,4) = 1;
index_H(index_H(:,2) == 1 & index_H(:,3) == 2,4) = 2;

index_H(index_H(:,2) == 2 & index_H(:,3) == 1,4) = 3;
index_H(index_H(:,2) == 2 & index_H(:,3) == 2,4) = 4;

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = zeros(length(source.pos),1);

for nroi = 1:4 
    source.pow(index_H(index_H(:,4) == nroi,1)) = nroi*10;
end

z_lim                   = 100;


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
% cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);

list_H = {'motor_L','motor_R','premotor_L','premotor_R'};

index_H = index_H(:,[1 4]);

clearvars -except index_H list_H;

save('../data_fieldtrip/index/broadman_based_motor_index.mat','index_H','list_H');

