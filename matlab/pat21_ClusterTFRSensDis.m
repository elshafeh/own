clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   '.all.wav.40t150Hz.m1000p1000.MinusEvoked.mat' ;
    lst_cnd   =   'RLN';
    lst_dis     =   {'DIS','fDIS'};
    
    for cnd = 1:length(lst_cnd)
        for cnd_dis = 1:2
            fname_in    = ['../data/tfr/' suj '.' lst_cnd(cnd) lst_dis{cnd_dis}   ext1];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            tf_dis{cnd_dis} = freq; clear freq ;
        end
        
        allsuj_GA{sb,cnd}           = tf_dis{1};
        allsuj_GA{sb,cnd}.powspctrm = tf_dis{1}.powspctrm - tf_dis{2}.powspctrm;
        clear tf_dis ;
    end
end

clearvars -except allsuj_GA 

[design,neighbours] = h_create_design_neighbours(size(allsuj_GA,1),'meg','t'); clc;

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [0.1 0.5];
cfg.frequency           = [60 100];
% cfg.avgoverfreq         = 'yes';
% cfg.avgovertime         = 'yes';
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;

stat{1}                 = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2}); 
stat{2}                 = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,3}); 
stat{3}                 = ft_freqstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,3});

for s = 1:length(stat)
    [min_p(s),p_val{s}] = h_pValSort(stat{s});
end

for s = 1:length(stat)
    stat2plot{s} = h_plotStat(stat{s},min_p(s)-0.01,0.1);
end

for cnd_s = 1:length(stat)
    figure;
    cfg                 = [];
    cfg.layout          = 'CTF275.lay';
    cfg.zlim            = [-0.05 0.05];
    cfg.comment         = 'no';
    cfg.marker          = 'off';
    ft_topoplotTFR(cfg,stat2plot{cnd_s})
end