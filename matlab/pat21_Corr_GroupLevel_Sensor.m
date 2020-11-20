clear ; clc ;  dleiftrip_addpath ;

load ../data/yctot/rt/rt_CnD_adapt.mat
load ../data/yctot/gavg/CnD_percentage_correct_gavg.mat;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.CnD.all.wav.14t50Hz.m2000p2000.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.4 -0.2];
    cfg.baselinetype            = 'relchange';
    allsuj_GA{sb,1}             = ft_freqbaseline(cfg,freq);
    
    clear freq fname suj
    
    allsuj_behav{sb,1}          = median(rt_all{sb});
    allsuj_behav{sb,2}          = mean(rt_all{sb});
    allsuj_behav{sb,3}          = sub_per{sb};
    
end

clearvars -except allsuj*

cfg         = [];
cfg.method  = 'template'; cfg.layout  = 'CTF275.lay'; neighbours  = ft_prepare_neighbours(cfg);clc;

cfg                     = [];
cfg.latency             = [0.5 1.2];
% cfg.frequency           = [2 7];
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT'; 
cfg.correctm            = 'cluster';cfg.type                = 'Spearman';  
cfg.clusterstatistics   = 'maxsum';cfg.clusteralpha        = 0.05;   
cfg.minnbchan           = 4;
cfg.tail                = 0;cfg.clustertail         = 0;
cfg.alpha               = 0.025;cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;cfg.ivar                = 1;            

cfg.design(1,1:14)      = [allsuj_behav{:,1}];
stat                    = ft_freqstatistics(cfg, allsuj_GA{:,1});

[min_p,p_val]           = h_pValSort(stat);

stat.mask               = stat.prob < 0.2;
corr2plot.label         = stat.label;
corr2plot.freq          = stat.freq;
corr2plot.time          = stat.time;
corr2plot.powspctrm     = stat.rho .* stat.mask;
corr2plot.dimord        = stat.dimord;

cfg                     = [];
cfg.layout              = 'CTF275.lay';
% cfg.xlim                = 0.5:0.1:1.2;
cfg.zlim                = [-0.01 0.01];
ft_topoplotTFR(cfg,corr2plot);