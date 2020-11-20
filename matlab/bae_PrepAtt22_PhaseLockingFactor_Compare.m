clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

for sb = 1:21
    
    suj           = ['yc' num2str(sb)];
    
    fname_in      = ['../data/' suj '/field/' suj '.DIS.waveletFOURIER.5t120Hz.m300p600.KeepTrials.Ang.ITC.mat'];
    fprintf('Loading %s\n',fname_in);
    load(fname_in)
    
    allsuj_activation{sb}                       = freq_itc;
    
    fname_in      = ['../data/' suj '/field/' suj '.fDIS.waveletFOURIER.5t120Hz.m300p600.KeepTrials.Ang.ITC.mat'];
    fprintf('Loading %s\n',fname_in);
    load(fname_in)
    
    allsuj_baselineRep{sb}                      = freq_itc;
    
    clear freq_*
    
end

nsuj                    = length(allsuj_activation);
[design,~]              = h_create_design_neighbours(nsuj,allsuj_activation{1},'meg','t'); clc;

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.000000005;
cfg.alpha               = 0.025;
cfg.tail                = 1;
cfg.clustertail         = 1;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

stat                    = ft_freqstatistics(cfg, allsuj_activation{:},allsuj_baselineRep{:});
stat                    = rmfield(stat,'cfg');

cfg                             = [];
cfg.parameter                   = 'stat';
cfg.colorbar                    = 'no';
cfg.maskparameter               = 'mask';
cfg.maskstyle                   = 'outline';
cfg.zlim                        = [0 30];
ft_singleplotTFR(cfg,stat);

% [min_p, p_val]          = h_pValSort(stat) ;
% plimit                  = 0.05;
% stat2plot               = h_plotStat(stat,0.000000000000000000000000000001,plimit);
%
% cfg                     = [];
% cfg.zlim                = [0 30];
% ft_singleplotTFR(cfg,stat2plot);