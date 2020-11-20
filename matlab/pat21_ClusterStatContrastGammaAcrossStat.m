clear;clc;dleiftrip_addpath;

cond = {'CnD','nDT','DIS','fDIS'};

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for b = 1:length(cond)
        fname = ['../data/tfr/' suj '.' cond{b} '.all.wav.40t150Hz.m2000p2000.MinusEvoked.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname); carr{b} = freq; clear freq;
    end
    
    cfg                             = [];
    cfg.baselinetype                = 'absolute';
    cfg.baseline                    = [-0.2 -0.1];
    allsuj_GA{sb,1}                 = ft_freqbaseline(cfg,carr{1});
    cfg.baseline                    = [-1.4 -1.3];
    allsuj_GA{sb,2}                 = ft_freqbaseline(cfg,carr{2});
    
    allsuj_GA{sb,3}                 = carr{3};
    allsuj_GA{sb,3}.powspctrm       = carr{3}.powspctrm - carr{4}.powspctrm;
    
    clear carr;
    
end

[design,neighbours] = h_create_design_neighbours(size(allsuj_GA,1),'meg','t'); clc;

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [0 0.5];
cfg.frequency           = [50 90];
% cfg.avgoverfreq         = 'yes';
% cfg.avgovertime         = 'yes';
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;

stat{1}                 = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2}); % CUE-TARGET
stat{2}                 = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,3}); % CUE-DIS
stat{3}                 = ft_freqstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,3}); % TARGET-DIS

for s = 1:length(stat)
    [min_p(s),p_val{s}] = h_pValSort(stat{s});
end

for s = 1:length(stat)
    stat2plot{s} = h_plotStat(stat{s},min_p(s)-0.01,0.2);
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