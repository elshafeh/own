clear ; clc ; dleiftrip_addpath ; close all ;

suj_list                                        = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                     = ['yc' num2str(suj_list(sb))];
    fname                                   = ['../data/tfr/' suj '.CnD.all.wav.14t50Hz.m2000p2000.mat'];
    
    fprintf('Loading %30s\n',fname);  load(fname);
    
    cfg                                     = [];
    cfg.latency                             = [0 2];
    allsuj_activation{sb}                   = ft_selectdata(cfg, freq);
    
    cfg                                     = [];
    bsl_period                              = [-0.4 -0.2];
    cfg.latency                             = bsl_period;
    cfg.avgovertime                         = 'yes';
    allsuj_baselineAvg{sb}                  = ft_selectdata(cfg, freq);allsuj_baselineRep{sb}  = allsuj_activation{sb};
    allsuj_baselineRep{sb}.powspctrm        = repmat(allsuj_baselineAvg{sb}.powspctrm,1,1,size(allsuj_activation{sb}.powspctrm,3));
    
end

clearvars -except allsuj_*  ext_bsl cond;

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cfg                     = [];
cfg.channel             = 'MEG';cfg.clusterstatistic    = 'maxsum'; cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_depsamplesT'; cfg.correctm            = 'cluster';

cfg.clusteralpha        = 0.05; 
cfg.minnbchan           = 4;

% cfg.frequency           = [2 7];
% cfg.latency             = [-0.1 1.2];

cfg.alpha               = 0.025;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;
stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});
stat                    = rmfield(stat,'cfg');

[min_p, p_val]          = h_pValSort(stat) ;

clustno                 = 1;
stat2plot               = h_plotStat(stat,p_val(1,clustno)-0.0001,p_val(1,clustno)+0.0001);
% stat2plot               = h_plotStat(stat,0.0001,0.1);

cfg         = [];
cfg.layout  = 'CTF275.lay';
% cfg.xlim    = [tlist(t) tlist(t)+0.1];
cfg.zlim    = [-1 1];
cfg.marker  = 'off';
ft_topoplotER(cfg,stat2plot);

tlist                   = 0:0.1:2;

for t = 1:length(tlist)
    figure;
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    cfg.xlim    = [tlist(t) tlist(t)+0.1];
    cfg.zlim    = [-3 3];
    cfg.marker  = 'off';
    ft_topoplotER(cfg,stat2plot);
end