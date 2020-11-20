% Run Non-parametric cluster based permutation tests against baseline

clear ; clc ; dleiftrip_addpath ; close all ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    lst         = {'nDT','DT','DT1','DT2','DT3'};
    ext1        = '.all.wav.40t150Hz.m2000p2000.MinusEvoked.mat' ;
    
    for cnd = 1:length(lst)
        fname_in    = ['../data/tfr/' suj '.' lst{cnd} ext1];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        bsl_period                                  = [-1.4 -1.3];
        act_period                                  = [0 0.6];
        
        cfg                                         = [];
        cfg.latency                                 = act_period;
        allsuj_activation{a,cnd}                    = ft_selectdata(cfg, freq);
        cfg                                         = [];
        cfg.latency                                 = bsl_period;
        cfg.avgovertime                             = 'yes';
        allsuj_baselineAvg{a,cnd}                   = ft_selectdata(cfg, freq);
        allsuj_baselineRep{a,cnd}                   = allsuj_activation{a,cnd};
        allsuj_baselineRep{a,cnd}.powspctrm         = repmat(allsuj_baselineAvg{a,cnd}.powspctrm,1,1,size(allsuj_activation{a,cnd}.powspctrm,3));
       
        clear freq ;
        
    end
end

clearvars -except *allsuj* ;

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cfg                     = [];
cfg.channel             = {'MLC22', 'MLC31', 'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC55', ...
    'MLC61', 'MLC62', 'MLC63', 'MLP12', 'MLP23', 'MRC14', 'MRC22', 'MRC23', 'MRC31', 'MRC32', ...
    'MRC41', 'MRC42', 'MRC51', 'MRC52', 'MRC53', 'MRC54', 'MRC55', 'MRC61', 'MRC62', 'MRC63', ...
    'MRP12', 'MRP23'};
cfg.avgoverchan         = 'yes';
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_depsamplesT';cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.tail                = 0;cfg.clustertail            = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours        = neighbours;cfg.uvar                = 1;cfg.ivar                = 2;
cfg.minnbchan           = 0;
cfg.frequency           = [60 90];
cfg.avgoverfreq         = 'yes';

for cnd = 1:size(allsuj_baselineRep,2)    
    stat{cnd}           = ft_freqstatistics(cfg, allsuj_activation{:,cnd},allsuj_baselineRep{:,cnd});
end

for cnd = 1:size(allsuj_baselineRep,2)
    [min_p(cnd), p_val{cnd}]     = h_pValSort(stat{cnd}) ;
    stat2plot{cnd}               = h_plotStat(stat{cnd},0.05);
end

figure;
for cnd = 1:5
    subplot(5,1,cnd)
    plot(stat2plot{cnd}.time,squeeze(stat2plot{cnd}.powspctrm));ylim([0 6]);
end

% for cnd = 1:size(allsuj_baselineRep,2)
%     figure;
%     cfg             = [];
%     cfg.zlim        = [-0.5 0.5];
%     cfg.comment     = 'no';
%     cfg.marker      = 'off';
%     cfg.layout      = 'CTF275.lay';
%     ft_topoplotTFR(cfg,stat2plot{cnd});
% end