cclear ; clc ;

for sb = 1:14
    
    ext_essai   = '.m1000p2000.1t100Hz.fourier.mat';
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    lst_cue         = {'R','L','N'};
    
    for cnd = 1:2
        
        load(['../data/tfr/' suj '.' lst_cue{cnd} 'CnD.m1000p2000.1t100Hz.plv.mat']);
        
        allsuj_GA{sb,cnd}.label         = plf.label;
        allsuj_GA{sb,cnd}.freq          = plf.freq;
        allsuj_GA{sb,cnd}.time          = plf.time;
        allsuj_GA{sb,cnd}.dimord        = plf.dimord;
        allsuj_GA{sb,cnd}.powspctrm     = plf.plf;

    end
    
end

clearvars -except allsuj_GA

[design,neighbours]     = h_create_design_neighbours(length(allsuj_GA),allsuj_GA{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
cfg.minnbchan           = 0;
cfg.latency             = [-0.1 2];
cfg.frequency           = [4 15];
stat                    = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});

[min_p,p_val] = h_pValSort(stat);

stat2plot               = h_plotStat(stat,0.0000000001,0.05);
figure;

for chn = 1:length(stat.label)
    subplot(2,1,chn)
    cfg                 = [];
    cfg.channel         = chn;
    cfg.zlim            = [-0.1 0.1];
    ft_singleplotTFR(cfg,stat2plot);clc;
end