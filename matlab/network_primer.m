clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load /Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data_fieldtrip/template/template_grid_1cm.mat
load /Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/yc21/field/yc21.RNCnD.p600p1000.7t11Hz.OriginalPCC100Slct.0.5cm.mat

new_source                  = [];
new_source.pos              = template_grid.pos;
new_source.avg.csd          = source.avg.csd(1:length(new_source.pos));
new_source.avg.noisecsd     = source.avg.noisecsd(1:length(new_source.pos));
new_source.avg.csdlabel     = source.avg.csdlabel(1:length(new_source.pos));
new_source.avg.mom          = source.avg.mom(1:length(new_source.pos));

cfg                         = [];
cfg.method                  = 'coh';
cfg.complex                 = 'absimag';
source_conn                 = ft_connectivityanalysis(cfg, new_source);

cfg             = [];
cfg.method      = 'degrees';
cfg.parameter   = 'cohspctrm';
cfg.threshold   = .1;
network_full    = ft_networkanalysis(cfg,source_conn);