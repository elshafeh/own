function reg_list = FindSigVoxels(source)

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
atlas_source        = ft_sourceinterpolate(cfg, atlas, source);

reg_list = {};

for d = 1:length(atlas.tissuelabel)   
    
    indxH                   =   find(atlas_source.tissue==d);
    
    for xi = 1:length(indxH);
        
        if source.pow(indxH(xi),1) ~= 0 && ~isnan(source.pow(indxH(xi),1))
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

reg_list = uni_list ;