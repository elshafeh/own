function indx = h_createIndexHesham(source)

for n = 1:length(source.avg.pow)
    source.avg.pow(n) = n;
end

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
mri                 = ft_read_mri('../fieldtrip-20151124/template/anatomy/single_subj_T1_1mm.nii');

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
atlasOnmri          = ft_sourceinterpolate(cfg, atlas, mri);
cfg.parameter       = 'pow';
sourceOnmri         = ft_sourceinterpolate(cfg, source, mri);

indx = [];

for d = 1:length(atlas.tissuelabel)
    
    ind_atlas               =   find(atlasOnmri.tissue==d);
    ind_source              =   sourceOnmri.pow(ind_atlas);
    ind_source              =   unique(ind_source);
    indx                    =   [indx ; ind_source repmat(d,size(ind_source,1),1)];
    
    clear ind_atlas ind_source
    
end