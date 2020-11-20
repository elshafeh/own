clear ; clc ; dleiftrip_addpath ;

% ../data/yctot/stat/VNndt.lcmv.N1.mat
% ../data/yctot/stat/new.dis.lcmv.stat.mat
% ../data/yctot/stat/nDT.lcmv.stat.mat
% ../data/yctot/stat/VNndt.lcmv.N1.mat

load ../data/yctot/stat/nDT.lcmv.stat.mat

stat_int                = h_interpolate(stat{1});
stat_int.coordsys       = 'mni';
stat_int.mask           = stat_int.prob < 0.05 ;

cfg                     = [];
cfg.method              = 'ortho';
cfg.atlas               = '../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii';
cfg.funparameter        = 'stat';
cfg.maskparameter       = 'mask';
cfg.funcolorlim         = [0 6];
cfg.location            = 'max';
ft_sourceplot(cfg,stat_int);

% list = FindSigClusters(stat{1},0.05);
% load ../data/yctot/BaselineSourceStat.mat ;
% mri  = ft_read_mri('../fieldtrip-20151124/template/anatomy/single_subj_T1_1mm.nii');
% for a = 2
%     for b = 1
%         stat_carr{a,b}.mask     = stat_carr{a,b}.prob < 0.1 ;
%         cfg                     = [];
%         cfg.parameter           = 'stat';
%         cfg.interpmethod        = 'nearest';
%         stat_int{a,b}           = ft_sourceinterpolate(cfg, stat_carr{a,b}, mri);
%         cfg.parameter           = 'mask';
%         maskint{a,b}            = ft_sourceinterpolate(cfg, stat_carr{a,b}, mri);
%         stat_int{a,b}.mask      = maskint{a,b}.mask;
%         
%         clear cfg clear maskint
%         
%         stat_int{a,b}.cfg.previous = [];
%     end
% end
% clearvars -except stat_int ; 
% a = 2; b = 1;
% stat_int{a,b}.maskedstat = stat_int{a,b}.mask .* stat_int{a,b}.stat;
% cnd_time = {'preTarget Early','preTarget Late','posTarget'};
% cnd_freq = {'low','high'};
% ind_slice = 77 ;
% for a = 1:3
%     for b = 1:2
%         stat_int{a,b}.coordsys  = 'mni';
%         cfg                     = [];
%         cfg.method              = 'slice';
%         cfg.funparameter        = 'stat';
%         %         cfg.atlas               = '../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii';
%         cfg.maskparameter       = 'mask';
%         cfg.nslices             = 1 ; % 16;
%         cfg.slicerange          = [ind_slice ind_slice] ; %[70 84];
%         cfg.funcolorlim         = [-6 6];
%         %         cfg.opacitymap = 'vdown';
%         %         cfg.funcolormap = 'jet';
%         ft_sourceplot(cfg,stat_int{a,b});clc;
%         saveFigure(gcf,['../plots/poster_prep/source_' cnd_time{a} ' ' cnd_freq{b} '.png'])
%         %         title([cnd_time{a} ' ' cnd_freq{b}])
%         %         set(gcf,'Color','none')
%         close all;
%     end
% end