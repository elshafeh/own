clear;

%load atlas and template MNI grid
load ../data/stock/template_grid_0.5cm.mat;
brainnetome                 = ft_read_atlas('~/github/fieldtrip/template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii');
brainnetome.tissuelabel     = brainnetome.tissuelabel';

template_grid               = ft_convert_units(template_grid,brainnetome.unit);

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;

%interpolate atlas on the grid 
cfg                         = [];
cfg.interpmethod            = 'nearest';
cfg.parameter               = 'tissue';
source_atlas                = ft_sourceinterpolate(cfg, brainnetome, source);

index_H                     = [];
source.pow                  = nan(length(source.pos),1);

% choose visual areas
vis_1                      	= [203 204];
vis_2                     	= [199 200 207 208];
vis_3                      	= [209 210];
vis_areas                   = [vis_1 vis_2 vis_3];

% choose auditory areas
aud_1                       = [71 72 124 145 146];
aud_2                       = [163 164];
aud_3                       = [75 76];
aud_areas                   = [aud_1 aud_2 aud_3];

% choose motor areas
mot_1                       = [162 161 160 155 156 ];
mot_2                       = [53 54 55 56 57 58 59 60];
mot_areas                   = [mot_1 mot_2];

roi_interest                = [vis_areas aud_areas mot_areas];

label_interest              = brainnetome.tissuelabel(roi_interest);

for d = 1:length(roi_interest)
    
    if ismember(roi_interest(d),vis_areas)
        flg                 = 0.5;
    elseif ismember(roi_interest(d),aud_areas)
        flg                 = 2;
    elseif ismember(roi_interest(d),mot_areas)
        flg                 = 3;
    end
    
    %     if ismember(roi_interest(d),mot_1)
    %         flg                 = 0.5;
    %     elseif ismember(roi_interest(d),mot_2)
    %         flg                 = 2;
    %     elseif ismember(roi_interest(d),aud_3)
    %         flg                 = 3;
    %     end
    %     flg                     = d;
    
    % find the index of each ROI in the MNI grid
    x                       =   find(ismember(brainnetome.tissuelabel,brainnetome.tissuelabel{roi_interest(d)}));
    indxH                   =   find(source_atlas.tissue==x);
    
    source.pow(indxH)       = flg;
    
    index_H                 =   [index_H ; indxH repmat(flg,size(indxH,1),1)];
    clear indxH x flg findme
    
end

%%

cfg                         = [];
cfg.method                  = 'surface';
cfg.funparameter            = 'pow';
% cfg.maskparameter           = cfg.funparameter;
% cfg.funcolorlim             = [-1 ];%max(index_H(:,2))];
cfg.funcolormap             = brewermap(12,'Spectral');
cfg.projmethod              = 'nearest';
cfg.camlight                = 'no';
cfg.surfinflated            = 'surface_white_both.mat';
list_view                   = [-90 0 0 ; 90 0 0; 0 0 90; 0 -90 0];

for nview = [1 2 3 4]
    ft_sourceplot(cfg, source);
    view (list_view(nview,:));
    material dull
    %     saveas(gcf,['~/Desktop/atlas_view' num2str(nview) '.png']); close all;
end