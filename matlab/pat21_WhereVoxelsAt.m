clear ; clc ; 

load ../data/yctot/index/conMaIndx.mat ;
load ../data/template/source_struct_template_MNIpos.mat ;

indx_tot = indx_tot(indx_tot(:,2) > 2 & indx_tot(:,2) < 79,:);

source.avg.pow(:,:) = 0 ;
source.avg.pow(indx_tot(:,1),:) = 10 ; 

source_int = h_interpolate(source) ;

cfg                     = [];
cfg.method              = 'slice';
cfg.funparameter        = 'pow';
% cfg.nslices             = 16;
% cfg.slicerange          = [70 84];
cfg.funcolorlim         = [0 10];
ft_sourceplot(cfg,source_int);clc;