function final_list = FindSigClustersMultiDimension(stat,p_threshold)

stat.mask           = stat.prob < p_threshold ;
atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

for nfreq = 1:length(stat.freq)
    for ntime   = 1:length(stat.time)
        
        source                  = [];
        atlas_stat              = [];
        uni_list                = {};
        reg_list                = {};
        
        source.pos              = stat.pos ;
        source.dim              = stat.dim ;
        tpower                  = stat.stat .* stat.mask;
        source.pow              = squeeze(tpower(:,nfreq,ntime)) ; clear tpower;
        
        cfg                     = [];
        cfg.interpmethod        = 'nearest';
        cfg.parameter           = 'tissue';
        atlas_stat              = ft_sourceinterpolate(cfg, atlas, source);
        
        for d = 1:length(atlas.tissuelabel)
            
            indxH               =   find(atlas_stat.tissue==d);
            
            for xi = 1:length(indxH);
                
                if source.pow(indxH(xi),1) ~= 0
                    reg_list{end+1} = atlas.tissuelabel{d};
                end
            end
            
            clear indxH
            
        end
        
        uni_list = unique(reg_list);
        uni_list = uni_list';
        
        for n = 1:length(uni_list)
            ix = find(strcmp(uni_list{n},reg_list));
            uni_list{n,2} = length(ix);
        end
        
        reg_list                = uni_list ; clear uni_list
        final_list{nfreq,ntime} = reg_list; clear reg_list 
        
    end
end