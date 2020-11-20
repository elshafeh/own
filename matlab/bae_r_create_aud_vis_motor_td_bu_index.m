clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

%% Atlas Brodmann

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

index_H = [indx(indx(:,2) > 38 & indx(:,2) < 42,:) ; indx(indx(:,2) > 61 & indx(:,2) < 64,:) ; indx(indx(:,2) == 30 ,:) ; indx(indx(:,2) == 32 ,:) ];  

index_H(index_H(:,2) >= 39 & index_H(:,2) <= 41 ,2) = 1; %visuel (V1, V2, associatif)
index_H(index_H(:,2) == 62 | index_H(:,2) == 63,2) = 2; %auditif (CA)
index_H(index_H(:,2) == 30 | index_H(:,2) == 32,2) = 3;

for n = 1:length(index_H)
    if source.pos(index_H(n,1),1) < 0
        index_H(n,3) = 1;
    else
        index_H(n,3) = 2;
    end
end

index_H(:,4) = 0;
%on distingue droite et gauche
index_H(index_H(:,2) == 1 & index_H(:,3) == 1,4) = 1; %visuel gauche
index_H(index_H(:,2) == 1 & index_H(:,3) == 2,4) = 2; %visuel droit

index_H(index_H(:,2) == 2 & index_H(:,3) == 1,4) = 3; %auditif gauche
index_H(index_H(:,2) == 2 & index_H(:,3) == 2,4) = 4; %auditif droit

index_H(index_H(:,2) == 3 & index_H(:,3) == 1,4) = 5; %moteur gauche
index_H(index_H(:,2) == 3 & index_H(:,3) == 2,4) = 6; %moteur droit

index_H = [index_H(:,1) index_H(:,4)];

%% Atlas Schaefer

atlas  = ft_read_atlas('../data_fieldtrip/Atlas_Schaefer2018/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_1mm.nii.gz');
%atlas.coordsys = 'NIfTI';

load ../data_fieldtrip/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = zeros(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'brick0';
source_atlas            = ft_sourceinterpolate(cfg,atlas,source);

indx = [];

for d = 1:length(atlas.brick0label)
    
    x                       =   find(ismember(atlas.brick0label,atlas.brick0label{d}));
    
    indxH                   =   find(source_atlas.brick0==x);
    
    indx                    =   [indx ; indxH repmat(d,size(indxH,1),1)];
    
    clear indxH x   
end

num_area = [16:30 67:78];

index_H = [index_H ; indx(indx(:,2) >= 16 & indx(:,2) <= 30,:) ; indx(indx(:,2) >= 67 & indx(:,2) <= 78,:)];  

index_H(index_H(:,2) >= 16 & index_H(:,2) <= 23 ,2) = 7; %TD gauche
index_H(index_H(:,2) >= 67 & index_H(:,2) <= 73 ,2) = 7; %TD droit

index_H(index_H(:,2) >= 24 & index_H(:,2) <= 30 ,2) = 8; %BU gauche
index_H(index_H(:,2) >= 74 & index_H(:,2) <= 78 ,2) = 8; %BU droit

%%
source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = nan(length(source.pos),1);


for nroi = 1:length(num_area)
    source.pow(index_H(index_H(:,2) == nroi,1)) = nroi;
end

cfg                                         =   [];
cfg.funcolormap                             = 'jet';
cfg.method                                  =   'surface';
cfg.funparameter                            =   'pow';
% cfg.funcolorlim                             =   [0 z_lim];
% cfg.opacitylim                              =   [0 z_lim];
cfg.opacitymap                              =   'rampup';
cfg.colorbar                                =   'on';
cfg.camlight                                =   'no';
% cfg.projthresh                              =   0.2;
cfg.projmethod                              =   'nearest';
cfg.surffile                                =   'surface_white_both.mat';
cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);
view([-95 1])

list_H = {'Vis_L','Vis_R','Aud_L','Aud_R','Motor_L','Motor_R','TD','BU'};

clearvars -except index_H list_H;

save('../data_fieldtrip/index/vis_aud_motor_TD_BU_index.mat','index_H','list_H');
