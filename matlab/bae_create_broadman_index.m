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

index_H = [indx(indx(:,2) > 38 & indx(:,2) < 42,:) ; indx(indx(:,2) > 61 & indx(:,2) < 64,:)];  

index_H(index_H(:,2) == 39,2) = 1;
index_H(index_H(:,2) == 40,2) = 2;
index_H(index_H(:,2) == 41,2) = 3;
index_H(index_H(:,2) == 62,2) = 4;
index_H(index_H(:,2) == 63,2) = 5;

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

index_H(index_H(:,2) == 3 & index_H(:,3) == 1,4) = 5;
index_H(index_H(:,2) == 3 & index_H(:,3) == 2,4) = 6;

index_H(index_H(:,2) == 4 & index_H(:,3) == 1,4) = 7;
index_H(index_H(:,2) == 4 & index_H(:,3) == 2,4) = 8;

index_H(index_H(:,2) == 5 & index_H(:,3) == 1,4) = 7;
index_H(index_H(:,2) == 5 & index_H(:,3) == 2,4) = 8;

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = nan(length(source.pos),1);

for nroi = 1:8 
    source.pow(index_H(index_H(:,2) == nroi,1)) = nroi*1;
end

z_lim                   = 10;


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

list_H = {'V1_L','V1_R','V2_L','V2_R','V3_L','V3_R','aud_L','aud_R'};

index_H = index_H(:,[1 4]);

clearvars -except index_H list_H;

save('../data_fieldtrip/index/broadman_based_audiovisual_index.mat','index_H','list_H');

