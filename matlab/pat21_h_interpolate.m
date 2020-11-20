function inter = h_interpolate(source)

% interpolate source (pow or stat) on mni template.
% in case of stat; interpolation will include stat (t-values) and prob
% (p-values). This way you can define your mask afterwards and you're not
% obliged to re-interpolate when you change mask.

mri = ft_read_mri('../fieldtrip-20151124/template/anatomy/single_subj_T1_1mm.nii'); % you should adjust this according to your directory

cfg                 = [];
cfg.interpmethod    = 'nearest';

if isfield(source,'avg') || isfield(source,'pow')
    param = 'pow';    
elseif isfield(source,'stat')
    param = {'stat','prob'};
end

cfg.parameter = param ;

inter = ft_sourceinterpolate(cfg,source,mri);