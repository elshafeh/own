clear;

for nvox = {'0.5'}
    
    load(['../data/template/template_grid_' nvox{:} 'cm.mat']);
    brainnetome                 = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii');
    brainnetome.tissuelabel     = brainnetome.tissuelabel';
    
    template_grid               = ft_convert_units(template_grid,brainnetome.unit);
    
    source                      = [];
    source.pos                  = template_grid.pos ;
    source.dim                  = template_grid.dim ;
    source.pow                  = nan(length(source.pos),1);
    
    cfg                         = [];
    cfg.interpmethod            = 'nearest';
    cfg.parameter               = 'tissue';
    source_atlas                = ft_sourceinterpolate(cfg, brainnetome, source);
    
    index_H                     = [];
    
    vis_areas                   = [199 200 203 204 205 206 207 208 209 210];
    aud_areas                   = [71 72 75 76 145 146];
    mot_areas                   = [131 132 53 54 55 56 57 58 59 60];
    
    in_lpfc                    	= [21 22];
    in_fef                      = [29 30];
    in_ips                      = [129 130 133 134 137 138];
    
    roi_interest                = sort([vis_areas aud_areas mot_areas in_lpfc in_fef in_ips in_ips]); %  
    
    label_interest              = brainnetome.tissuelabel(roi_interest);
    
    for d = 1:length(roi_interest)
        
        findme                  = roi_interest(d);
        
        if ismember(findme,vis_areas)
            flg                 = 1;
        elseif ismember(findme,aud_areas)
            flg                 = 2;
        elseif ismember(findme,mot_areas)
            flg                 = 3;
        elseif ismember(findme,in_lpfc)
            flg                 = 4;
        elseif ismember(findme,in_fef)
            flg                 = 5;
        elseif ismember(findme,in_ips)
            flg                 = 6;
            
        end
        
        x                       =   find(ismember(brainnetome.tissuelabel,brainnetome.tissuelabel{roi_interest(d)}));
        indxH                   =   find(source_atlas.tissue==x);
        index_H                 =   [index_H ; indxH repmat(flg,size(indxH,1),1)];
        clear indxH x flg findme
        
    end
    
    for nroi = 1:max(index_H(:,2))
        source.pow(index_H(index_H(:,2) == nroi,1)) = nroi;
    end
    
    cfg = [];
    cfg.method                              = 'surface';
    cfg.funparameter                        = 'pow';
    cfg.maskparameter                       = cfg.funparameter;
    cfg.funcolorlim                         = [0 max(unique(index_H(:,2)));];
    %     cfg.funcolormap                         = brewermap(10,'*Rd');
    %     cfg.opacitylim                          = cfg.funcolorlim;
    cfg.opacitymap                          = 'rampup';
    cfg.projmethod                          = 'nearest';
    cfg.camlight                            = 'no';
    cfg.surffile                            = 'surface_white_both.mat';
    cfg.surfinflated                        = 'surface_inflated_both.mat';
    
    ft_sourceplot(cfg, source);
    view([-90 0]);
    
    ft_sourceplot(cfg, source);
    view([90 0]);
    
    ft_sourceplot(cfg, source);
    view([0 90]);
    
end