% Verify that index you created are where you want them to be XD

clear ; clc ; close all ; dleiftrip_addpath ;

load('../data/yctot/index/Frontal.mat');

% indx_arsenal    = indx_arsenal(indx_arsenal(:,2) == 9,:);
indx_arsenal    = indx_arsenal(indx_arsenal(:,2) == 12 | indx_arsenal(:,2) == 16 ...
    | indx_arsenal(:,2) == 6 | indx_arsenal(:,2) == 9,:);

list_arsenal    = list_arsenal(5:10);
roi_list        = unique(indx_arsenal(:,2));

load ../data/template/source_struct_template_MNIpos.mat;

source                               = rmfield(source,'freq');    
source                               = rmfield(source,'method'); 
source                               = rmfield(source,'cumtapcnt');
source.pow                           = source.avg.pow;
source                               = rmfield(source,'avg');
source.pow(:,:)                      = NaN ;

for n = 1:length(roi_list)
    ix                          = indx_arsenal(indx_arsenal(:,2) == roi_list(n),1);
    %     source.pow(ix,:)            = n*10 ;
    source.pow(ix,:)            = 100 ;
end

% cfg                     =   [];
% cfg.method              =   'surface';
% cfg.funparameter        =   'pow';
% cfg.funcolorlim         =   [0 length(roi_list)*10];
% cfg.opacitylim          =   [0 length(roi_list)*10];
% cfg.opacitymap          =   'rampup';
% cfg.colorbar            =   'off';
% cfg.camlight            =   'no';
% cfg.projthresh          =   0.2; 
% cfg.projmethod          =   'nearest';
% cfg.surffile            =   'surface_white_both.mat';
% cfg.surfinflated        =   'surface_inflated_both_caret.mat';
% ft_sourceplot(cfg, source);

source_int = h_interpolate(source);

cfg                         = [];
cfg.method                  = 'slice';
cfg.funparameter            = 'pow';
cfg.nslices                 = 1;
cfg.slicerange              = [125 130];
cfg.funcolorlim             = [0 length(roi_list)*10];
ft_sourceplot(cfg,source_int);clc;

% reg_list = FindNonEmptyClusters(source);