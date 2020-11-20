function index = h_createDicsMaxIndex(stat,threshold,reg)

[~,vox_indx]            = h_findStatMaxVoxelPerRegion(stat,threshold,reg,1);

index                   = [];

if ~isempty(vox_indx)
    
    center_vox              = vox_indx(1,1);
    
    center_pos              = stat.pos(center_vox,:);
    
    all_vox                 = [];
    all_vox                 = [all_vox;center_pos];
    
    all_vox                 = [all_vox ; center_pos + [-0.5 0 0 ]];
    all_vox                 = [all_vox ; center_pos + [0.5 0 0]];
    all_vox                 = [all_vox ; center_pos + [0 -0.5 0]];
    all_vox                 = [all_vox ; center_pos + [0 0.5 0]];
    
    
    for nvox = 1:length(all_vox)
        
        stat_pos            = stat.pos;
        index               = [index ; find(stat_pos(:,1) == all_vox(nvox,1) & stat_pos(:,2) == all_vox(nvox,2) & stat_pos(:,3) == all_vox(nvox,3))];
        
    end
    
    
end

% load ../data_fieldtrip/template/template_grid_0.5cm.mat

% source                  = [];
% source.pos              = template_grid.pos ;
% source.dim              = template_grid.dim ;
% source.pow              = nan(length(source.pos),1);
% 
% source.pow(index)       = 5;
% 
% z_lim                   = 10;
% 
% 
% cfg                     =   [];
% cfg.method              =   'surface';
% cfg.funparameter        =   'pow';
% cfg.funcolorlim         =   [0 z_lim];
% cfg.opacitylim          =   [0 z_lim];
% cfg.opacitymap          =   'rampup';
% cfg.colorbar            =   'off';
% cfg.camlight            =   'no';
% cfg.projmethod          =   'nearest';
% cfg.surffile            =   'surface_white_both.mat';
% cfg.surfinflated        =   'surface_inflated_both_caret.mat';
% ft_sourceplot(cfg, source);