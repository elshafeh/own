clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

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

index_H = [indx(indx(:,2) >= 16 & indx(:,2) <= 30,:) ; indx(indx(:,2) >= 67 & indx(:,2) <= 78,:)];  

% index_H = []; 

ii=0;

for i = num_area
    
%     tmp = indx(indx(:,2) == i,:);
%     
%     ii = ii+1;
%     
%     tmp(:,2) = ii;
%     
%     index_H = [index_H ;tmp];
%     
%     clear tmp
    
        index_H = [index_H ; indx(indx(:,2) == i,:)];
    
        ii = ii+1;
        index_H(index_H(:,2) == i,2) = ii;
    
end

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = nan(length(source.pos),1);


for nroi = 1:length(num_area)
    source.pow(index_H(index_H(:,2) == nroi,1)) = nroi;
end
% 
% for nroi = 1:length(num_area)
%     switch nroi
%         case {1,2,3,4,5,6,16,17,18,19,20}
%            source.pow(index_H(index_H(:,2) == nroi,1)) = 1;
%         case {7,8,21,22}
%            source.pow(index_H(index_H(:,2) == nroi,1)) = 2;
%         case {9,23,24}
%            source.pow(index_H(index_H(:,2) == nroi,1)) = 3;
%         case {10,11,25}
%            source.pow(index_H(index_H(:,2) == nroi,1)) = 4;
%         case 12
%            source.pow(index_H(index_H(:,2) == nroi,1)) = 5; 
%         case {13,14,15,26,27}
%            source.pow(index_H(index_H(:,2) == nroi,1)) = 6;
%     end
% end



z_lim                   = length(num_area);

cfg                                         =   [];
cfg.funcolormap                             =   'jet';
cfg.method                                  =   'surface';
cfg.funparameter                            =   'pow';
cfg.funcolorlim                             =   [0 z_lim];
cfg.opacitylim                              =   [0 z_lim];
cfg.opacitymap                              =   'rampup';
cfg.colorbar                                =   'off';
cfg.camlight                                =   'no';
% cfg.projthresh                              =   0.2;
cfg.projmethod                              =   'nearest';
cfg.surffile                                =   'surface_white_both.mat';
% cfg.surfinflated                            =   'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);
view([-95 1])

list_H = atlas.brick0label(num_area);

clearvars -except index_H list_H;

save('../data_fieldtrip/index/Schaefer2018_TDBU_index.mat','index_H','list_H');

