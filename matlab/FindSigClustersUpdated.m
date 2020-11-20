function  big_reg_list = FindSigClustersUpdated(stat,p_threshold)

atlas                   = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

source                  = [];
source.pos              = stat.pos ;
source.dim              = stat.dim ;
source.pow              = stat.stat .* stat.mask;

cfg                     = [];
cfg.interpmethod        = 'nearest';
cfg.parameter           = 'tissue';
atlas_stat              = ft_sourceinterpolate(cfg, atlas, source);

reg_list                = {};
big_reg_list            = {};
ix                      = 0;

for d = 1:length(atlas.tissuelabel)   
    
    indxH               = find(atlas_stat.tissue==d);
    reg_list{d,1}       = atlas.tissuelabel{d};
    reg_list{d,2}       = [];

    for xi = 1:length(indxH);
        
        if stat.prob(indxH(xi),1) < p_threshold
            reg_list{d,2}       = [reg_list{d,2};indxH(xi) stat.stat(indxH(xi)) abs(stat.stat(indxH(xi)))];
        end
       
    end
    
    reg_list{d,3}       = length(reg_list{d,2});
    
    if reg_list{d,3} ~= 0

        ix = ix + 1;

        big_reg_list{ix,1} = reg_list{d,1};
        big_reg_list{ix,2} = sortrows(reg_list{d,2},3);
        big_reg_list{ix,3} = reg_list{d,3};

    end
    
end