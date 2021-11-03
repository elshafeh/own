clear ; clc ; close all;

% load in atlas

dir_field               = '~/github/fieldtrip/template/atlas/aal/';
atlas                	= ft_read_atlas([dir_field 'ROI_MNI_V4.nii']);
atlas.tissuelabel   	= atlas.tissuelabel';
atlas_param            	= 'tissue';
atlas               	= ft_convert_units(atlas,'cm');

load ../data/stock/template_grid_0.5cm.mat

% create source structure to interpolate the atlas onto

source                 	= [];
source.pos            	= template_grid.pos ;
source.inside         	= template_grid.inside ;
source.dim             	= template_grid.dim ;
source.pow            	= zeros(length(source.pos),1);

cfg                  	= [];
cfg.interpmethod      	= 'nearest'; % 
cfg.parameter         	= atlas_param;
source_atlas         	= ft_sourceinterpolate(cfg, atlas, source);

% choose visual areas
vis_areas             	= [43 44 49 50 51 52 53 54];
% choose auditory areas
aud_areas             	= [79 80 81 82]; 
% choose motor areas
mot_areas             	= [1 2];

roi_interest          	= [mot_areas vis_areas aud_areas]; % 
index_vox             	= [];

for d = 1:length(roi_interest)
    
    x                	=  find(ismember(atlas.tissuelabel,atlas.tissuelabel{roi_interest(d)}));
    indxH             	=   find(source_atlas.tissue==x);
    
    index_vox        	=  [index_vox ; indxH repmat(d,size(indxH,1),1)];
    
    if ismember(roi_interest(d),aud_areas)
        ext_modality  	= 'aud atlas';
    elseif ismember(roi_interest(d),mot_areas)
        ext_modality 	= 'mot atlas';
    elseif ismember(roi_interest(d),vis_areas)
        ext_modality  	= 'vis atlas';
    end
    
    % extract name and remove underscores
    name_roi            = atlas.tissuelabel{roi_interest(d)};
    name_roi(strfind(name_roi,'_')) = ' ';
    
    % add in the "modality" - this makes it easier to sub-select data with
    % FT
    index_name{d}       =  [ext_modality ' ' name_roi];
    
    
    clear indxH x
    
end

% this plot the atlas

save('~/Dropbox/project_me/data/pam/index/pam_alpha_5mm_aal_index.mat','index_vox','index_name');

% plot_atlas                      = 'no';
% 
% if strcmp(plot_atlas,'yes')
%     
%     source.pow                  = nan(length(source.pos),1);
%     source.pow(index_vox(:,1))      = index_vox(:,2);
%     
%     % left right top views
%     list_view                 	= [-90 0 0 ; 90 0 0; 0 0 90; 0 -90 0];
%     
%     cfg_caret                	= [];
%     cfg_caret.method         	= 'surface';
%     cfg_caret.funparameter    	= 'pow';
%     cfg_caret.funcolormap    	= brewermap(16,'Spectral');
%     cfg_caret.projmethod      	= 'nearest';
%     cfg_caret.camlight         	= 'no';
%     cfg_caret.surffile         	= 'surface_white_both.mat'; %; %'surface_pial_both.mat'; %'surface_white_both.mat';
%     cfg_caret.surfinflated     	= 'surface_inflated_both_caret.mat';
%     
%     cfg_infla               	= [];
%     cfg_infla.method          	= 'surface';
%     cfg_infla.funparameter   	= 'pow';
%     cfg_infla.funcolormap    	= brewermap(16,'Spectral');
%     cfg_infla.projmethod      	= 'nearest';
%     cfg_infla.camlight        	= 'no';
%     cfg_infla.surffile         	= 'surface_white_both.mat';
%     cfg_infla.surfinflated     	= 'surface_inflated_both.mat';
%     
%     cfg_nofla                 	= [];
%     cfg_nofla.method          	= 'surface';
%     cfg_nofla.funparameter     	= 'pow';
%     cfg_nofla.funcolormap    	= brewermap(16,'Spectral');
%     cfg_nofla.projmethod      	= 'nearest';
%     cfg_nofla.camlight        	= 'no';
%     cfg_nofla.surffile        	= 'surface_white_both.mat';
%     
%     for nview = 1
%         
%         ft_sourceplot(cfg_caret, source);
%         view (list_view(nview,:));
%         material dull
%         title('AAL parcels caret inflation');
%         
%         ft_sourceplot(cfg_infla, source);
%         view (list_view(nview,:));
%         material dull
%         title('AAL parcels inflation');
%         
%         
%         ft_sourceplot(cfg_nofla, source);
%         view (list_view(nview,:));
%         material dull
%         title('AAL parcels no inflation');
%         
%     end
%     
% end