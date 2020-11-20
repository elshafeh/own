function  reg_list = PlotSignificantVoxelsInAtlasRegion(stat,p_threshold)

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
atlas_stat          = ft_sourceinterpolate(cfg, atlas, stat);

reg_list = [];

for d = 1:length(atlas.tissuelabel)   
    
    indxH                   =   find(atlas_stat.tissue==d);
    
    for xi = 1:length(indxH);
        
        if stat.prob(indxH(xi),1) < p_threshold

            reg_list = [reg_list; indxH(xi) d];
        
        end       
    end
    
    clear indxH
    
end