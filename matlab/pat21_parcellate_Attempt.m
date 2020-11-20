clear;clc;

load atlas_MMP1.0_4k.mat ; mmp_atlas = atlas ; clear atlas ;

atlas = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
atlas = ft_convert_units(atlas,'cm');% assure that atlas and template_grid are expressed in the %same units
 
load ../data/template/template_grid_5mm.mat
load ../data/template/source_struct_template_MNIpos.mat ; 

template_source.pos = source.pos;
template_source.pow = source.avg.pow;
template_source.inside = source.inside;
template_source.dimord = 'pos';
template_source.dim = source.dim;

clear source;

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
source_atlas        = ft_sourceinterpolate(cfg, atlas, template_source);

% cfg=[];

indx            = h_createIndexfieldtrip;

new_atlas.pos           = template_source.pos ;
new_atlas.parcellation  = zeros(length(new_atlas.pos),1);

for n = 1:length(indx)
   new_atlas.parcellation(indx(n,1),1) = indx(n,2);
end

new_atlas.parcellationlabel = atlas.tissuelabel;
new_atlas.unit = 'cm';

parcel = ft_sourceparcellate([], template_source, new_atlas);

clearvars -except new_atlas ;

% for n = 1:length(new_atlas.pos)
%
%     xi = find(indx(:,1) == n,2);
%
%     if isempty(xi)
%         new_atlas.parcellation(n,1) =NaN;
%     else
%         new_atlas.parcellation(n,1) =xi;
%     end
%
% end