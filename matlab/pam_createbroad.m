clear;

ft_path                 = '~/github/fieldtrip/template/atlas/afni/';
current_path            = '/Users/heshamelshafei/github/own/matlab/';

cd(ft_path);
atlas                   = ft_read_atlas('~/github/fieldtrip/template/atlas/afni/TTatlas+tlrc.HEAD');
atlas                   = ft_convert_units(atlas,'cm');

cd(current_path);
load ../data/stock/template_grid_0.1cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.inside          	= template_grid.inside ;
source.pow              = zeros(length(source.pos),1);

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'brick1'; 
source_atlas            = ft_sourceinterpolate(cfg, atlas, source);

%%

% choose visual areas
vis_areas           	= [39 40 41];
% choose auditory areas
aud_areas           	= [62 63 44]; 
% choose motor areas
mot_areas            	= [30 32]; %[27 28 29]; % 

roi_interest          	= [mot_areas vis_areas aud_areas]; % 

index_vox               = [];
index_name              = {};
roi_found               = 0;

for d = 1:length(roi_interest)
    
    x               	=  find(ismember(atlas.brick1label,atlas.brick1label{roi_interest(d)}));
    both_hemi           =  find(source_atlas.brick1==x);
    
    for nhemi = [1 2]
        
        check_pos       = [both_hemi source.pos(both_hemi,:)];
        list_hemi       = {'left' 'right'};
        if nhemi == 1
            indxH       = check_pos(check_pos(:,2) < 0,1);
        else
            indxH       = check_pos(check_pos(:,2) > 0,1);
        end
        
        %         %         fill in parcels
        %         indxH                   = fill_parcel(indxH,source);
        
        if ~isempty(indxH)
            roi_found                   = roi_found + 1;
            index_vox                   =  [index_vox ; indxH repmat(roi_found,size(indxH,1),1)];
            index_name{roi_found,1} 	=  [atlas.brick1label{roi_interest(d)} ' ' list_hemi{nhemi}];
        end
        
    end
    
    clear indxH x   
    
end

%%

source.pow                      = nan(length(source.pos),1);
source.pow(index_vox(:,1))      = index_vox(:,2);

list_view                       = [-90 0 0 ; 90 0 0; 0 0 90; 0 -90 0];

cfg_caret                     	= [];
cfg_caret.method               	= 'surface';
cfg_caret.funparameter         	= 'pow';
cfg_caret.funcolormap         	= brewermap(16,'Spectral');
cfg_caret.projmethod          	= 'nearest';
cfg_caret.camlight            	= 'no';
cfg_caret.surffile            	= 'surface_white_both.mat'; %; %'surface_pial_both.mat'; %'surface_white_both.mat';
cfg_caret.surfinflated        	= 'surface_inflated_both_caret.mat';

cfg_infla                     	= [];
cfg_infla.method               	= 'surface';
cfg_infla.funparameter         	= 'pow';
cfg_infla.funcolormap         	= brewermap(16,'Spectral');
cfg_infla.projmethod          	= 'nearest';
cfg_infla.camlight            	= 'no';
cfg_infla.surffile            	= 'surface_white_both.mat';
cfg_infla.surfinflated        	= 'surface_inflated_both.mat';

cfg_nofla                     	= [];
cfg_nofla.method               	= 'surface';
cfg_nofla.funparameter         	= 'pow';
cfg_nofla.funcolormap         	= brewermap(16,'Spectral');
cfg_nofla.projmethod          	= 'nearest';
cfg_nofla.camlight            	= 'no';
cfg_nofla.surffile            	= 'surface_white_both.mat';


for nview = [1 2]
    
    ft_sourceplot(cfg_caret, source);
    view (list_view(nview,:));
    material dull
    title('Brod parcels caret inflation');
    
    ft_sourceplot(cfg_infla, source);
    view (list_view(nview,:));
    material dull
    title('Brod parcels inflation');
    
    
    ft_sourceplot(cfg_nofla, source);
    view (list_view(nview,:));
    material dull
    title('Brod parcels no inflation');
    
end