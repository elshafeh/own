clear; clc ; dleiftrip_addpath ;

suj = 'yc2' ;

load ../data/yctot/old/stat4roi.mat

load(['../data/' suj '/headfield/' suj '.VolGrid.1cm.mat']);

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'tissue';
stat_atlas          = ft_sourceinterpolate(cfg, atlas, stat);

load ../data/template/template_grid_1cm.mat

roi = atlas.tissuelabel(79:80); % Heschl_L and Heshcl_R

template_grid       =   ft_convert_units(template_grid,'mm');

posH = [];

for d = 1:length(roi)
    
    x                       =   find(ismember(atlas.tissuelabel,roi{d}));
    indxH                   =   find(stat_atlas.tissue==x);
    posH                    =   [posH;template_grid.pos(indxH,:) repmat(d,size(template_grid.pos(indxH,:),1),1)];                       % xyz positions in mni coordinates
    
end

% posH_src = [];
% 
% for d = 1:length(roi)
%     
%     x                           =   find(ismember(atlas.tissuelabel,roi{d}));
%     indxH_src                   =   find(srce_atlas.tissue==x);
%     posH_src                    =   [posH_src;template_grid.pos(indxH_src,:) repmat(d,size(template_grid.pos(indxH_src,:),1),1)];                       % xyz positions in mni coordinates
%     
% end

clearvars -except roi posH* suj *atlas; clc;


% How to find using atlas

cnd = {''}; % Note that you've calculated the covariance matrix on the entire epoch .. maybe not the greateast idea

mri                 =   ft_read_mri(['../mri/' suj '_T1_converted_V2.mri']);
norm                =   ft_volumenormalise([],mri);

posb                =   ft_warp_apply(norm.params,posH(:,1:3),'sn2individual');
btiposH             =   ft_warp_apply(pinv(norm.initial),posb);          % xyz positions in individual coordinates
btiposH             =   btiposH/10;

indx = [];

for a = 1:size(btiposH,1)
    for b = 1:size(btiposH,2)
        indx(a,b) = find_in_3d(round(btiposH(a,b),5),round(grid.pos,5));
    end
end

indx = indx(:,1);

clearvars -except indx suj

load(['../data/' suj '/source/' suj '.pt3.CnD.all.mtmfft.12t14Hz.p1400p1800.bsl.source.mat'])

source.avg.pow(:,:)         = -200 ;
source.avg.pow(indx,:)      = 200 ;

mri = ft_read_mri(['../mri/' suj '_T1_converted_V2.mri']);
mni = ft_read_mri('../fieldtrip-20151124/template/anatomy/single_subj_T1_1mm.nii');

cfg              = [];
cfg.parameter    = 'pow';
cfg.interpmethod = 'nearest';
source_mri       = ft_sourceinterpolate(cfg, source, mri);
source_mni       = ft_sourceinterpolate(cfg, source, mni);

% atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
% 
% source_mni.coordsys   = 'mni';

cfg                 = [];
cfg.method          = 'slice';
cfg.funparameter    = 'pow';
cfg.nslices         = 16;
ft_sourceplot(cfg,source_mri);
ft_sourceplot(cfg,source_mni);