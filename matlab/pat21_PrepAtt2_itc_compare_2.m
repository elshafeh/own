clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext_essai   = '.CnD.RamaBigCov.waveletFOURIER.5t15Hz.m3000p3000.mat';
    
    fname_in = [suj ext_essai];
    fprintf('\nLoading %50s \n\n',fname_in);
    load(['../data/tfr/' fname_in]);
    
    big_freq        = freq ; clear freq ;
    
    for cnd = 1:3
        
        cfg                 = [];
        cfg.channel         = 88:91;
        cfg.trials          = h_chooseTrial(big_freq,cnd-1,0,1:4);
        allsuj_GA{sb,cnd}   = ft_selectdata(cfg,big_freq);
        
    end
    
    clear big_freq 
    
end

clearvars -except allsuj_GA

allsuj_GA               = h_normalise_trials(allsuj_GA);
[design,neighbours]     = h_create_design_neighbours(length(allsuj_GA),allsuj_GA{1,1},'virt','itc2');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'diff_itc';
cfg.complex             = 'diffabs';
cfg.parameter           = 'fourierspctrm';
% cfg.correctm            = 'cluster';
cfg.correctm            = 'fdr';
cfg.clusteralpha        = 0.005;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
cfg.frequency           = [5 15];
cfg.latency             = [0 2];

stat                    = ft_freqstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,3});

[min_p,p_val] = h_pValSort(stat);

stat2plot            = h_plotStat(stat,0.0000000001,0.05);
figure;

for chn = 1:length(stat.label)
    subplot(2,2,chn)
    cfg                 = [];
    cfg.channel         = chn;
    cfg.zlim            = [-0.1 0.1];
    ft_singleplotTFR(cfg,stat2plot);
end