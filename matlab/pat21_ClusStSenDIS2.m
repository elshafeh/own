clear ; clc ; dleiftrip_addpath ; close all ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.DIS.all.wav.40t100Hz.m1500p500.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname); tmp{1}     = freq; clear freq
    
    fname = ['../data/tfr/' suj '.fDIS.all.wav.40t100Hz.m1500p500.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);tmp{2}     = freq; clear freq
    
    %     for d = 1:2
    %         cfg                 = [];
    %         cfg.baseline        = [-1 -0.9];
    %         cfg.baselinetype    = 'absolute';
    %         tmp{d}              = ft_freqbaseline(cfg,tmp{d});
    %     end
    
    %     cfg                                     = [];
    %     cfg.parameter                           = 'powspctrm';
    %     cfg.operation                           = 'subtract';
    %     freq                                    = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
    
    cfg                                             = [];
    cfg.latency                                     = [0 0.5];
    allsuj_activation{sb,1}                         = ft_selectdata(cfg, tmp{1});
    allsuj_baselineRep{sb,1}                        = ft_selectdata(cfg, tmp{2});
    
    %     cfg                                     = [];
    %     cfg.latency                             = [-0.2 -0.1];
    %     cfg.avgovertime                         = 'yes';
    %     allsuj_baselineAvg{sb,1}                = ft_selectdata(cfg, freq);
    %
    %     allsuj_baselineRep{sb,1}                = allsuj_activation{sb,1};
    %     allsuj_baselineRep{sb,1}.powspctrm      = repmat(allsuj_baselineAvg{sb,1}.powspctrm,1,1,size(allsuj_activation{sb,1}.powspctrm,3));
    
    clear allsuj_baselineAvg tmp;
end

clearvars -except *allsuj_* ;

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cfg                     = [];
cfg.channel             = 'MEG';cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;
cfg.minnbchan           = 2;
stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});

[min_p, p_val]          = h_pValSort(stat) ;
stat2plot               = h_plotStat(stat,0.06);
stat2plot.powspctrm(stat2plot.powspctrm<0) = 0 ;

cfg                     =   [];
cfg.zlim                =   [-0.1 0.1];
cfg.layout              = 'CTF275.lay';
cfg.comment             = 'no';
cfg.marker              = 'off';
ft_topoplotTFR(cfg,stat2plot);

lstChn = {'MLC16', 'MLC17', 'MLF56', 'MLF66', 'MLF67', 'MLP45',...
    'MLP56', 'MLP57', 'MLT12', 'MLT13', 'MLT14', 'MLT15', 'MLT22', 'MLT23', ...
    'MLT24', 'MLT25', 'MLT33', 'MLT34', 'MLT35', 'MLT43', 'MLT44'};

cfg             = [];
cfg.channel     = lstChn;
cfg.zlim        = [-1 1];
ft_singleplotTFR(cfg,stat2plot);
title('');

