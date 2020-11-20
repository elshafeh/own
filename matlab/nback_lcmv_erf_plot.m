clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

for n_suj = 1:length(suj_list)
    
    fname                                           = ['../../data/erf/sub' num2str(suj_list(n_suj)) '.brainbroadband.erf.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    avg.avg                                         = abs(avg.avg);
    
    ix1                                             = find(round(avg.time,2) == -0.1);
    ix2                                             = find(round(avg.time,2) == 0);
    
    pow                                             = avg.avg;
    bsl                                             = mean(avg.avg(:,ix1:ix2),2);
    avg.avg                                         = (pow - bsl) ./ bsl;
    
    ix1                                             = find(round(avg.time,2) == 0.05);
    ix2                                             = find(round(avg.time,2) == 0.3);
    
    mtrx                                            = mean(avg.avg(:,ix1:ix2),2);
    source                                          = h_towholebrain(mtrx,'../../data/template/com_btomeroi_select.mat','../../data/template/template_grid_0.5cm.mat');
    alldata{n_suj,1}                                = source; clear source mtrx avg data;
    
end

keep alldata data_list

cfg                                                  =   [];
cfg.method                                           =   'surface';
cfg.funparameter                                     =   'pow';
cfg.funcolorlim                                      =   'maxabs';
cfg.opacitylim                                       =   cfg.funcolorlim;
cfg.opacitymap                                       =   'rampup';
cfg.colorbar                                         =   'off';
cfg.camlight                                         =   'yes';
cfg.projmethod                                       =   'nearest';
cfg.surffile                                         =   'surface_white_both.mat';
cfg.surfinflated                                     =   'surface_inflated_both_caret.mat';
cfg.funcolormap                                      =  brewermap(9,'*RdYlBu');
for val   = [0.7 0.75 0.8 0.85]
    cfg.projthresh                                   = val;
    ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:}));
    view([14 44]);
end