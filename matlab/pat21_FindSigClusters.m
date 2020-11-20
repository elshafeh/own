function  reg_list = FindSigClusters(stat,p_threshold)

atlas                   = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

source                  = [];
source.pos              = stat.pos ;
source.dim              = stat.dim ;
source.pow              = stat.stat .* stat.mask;

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'tissue';
atlas_stat              = ft_sourceinterpolate(cfg, atlas, source); 

reg_list = {};

for d = 1:length(atlas.tissuelabel)   
    
    indxH                   =   find(atlas_stat.tissue==d);
    
    for xi = 1:length(indxH);
        
        if stat.prob(indxH(xi),1) < p_threshold
            reg_list{end+1} = atlas.tissuelabel{d};
        end       
    end
    
    clear indxH
    
end

uni_list = unique(reg_list);
uni_list = uni_list';

for n = 1:length(uni_list)
    ix              = find(strcmp(uni_list{n},reg_list));
    uni_list{n,2}   = length(ix);
end

reg_list = uni_list ;