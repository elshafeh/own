clear;clc;dleiftrip_addpath;

cond = {'LnDT','NnDT'};

suj_list = [1:4 8:17];

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))];
    
    for b = 1:length(cond)
        
        fname = ['../data/tfr/' suj '.' cond{b} '.all.wav.1t100Hz.m1500p1500.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        cfg                         = [];
        cfg.baseline                = [-0.4 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj_GA{a,b}              = ft_freqbaseline(cfg,freq);
        
        clear freq
        
    end
    
end

clearvars -except allsuj_GA

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

f_list              = [4 7;8 15; 16 30;30 50;50 90];

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [-0.2 0.6];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;

for cnd_f = 1:length(f_list)
    
    cfg.frequency           = [f_list(cnd_f,1) f_list(cnd_f,2)];
    stat{cnd_f}             = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
    stat{cnd_f}             = rmfield(stat{cnd_f},'cfg');
    
end

for cnd_f = 1:size(stat,2)
    [min_p(cnd_f), p_val{cnd_f}]      = h_pValSort(stat{cnd_f}) ;
    stat2plot{cnd_f}                  = h_plotStat(stat{cnd_f},0.1,'no');
end

for cnd_f = 1:size(stat,2)
    
    figure;
    cfg         =   [];
    cfg.xlim    =   -0.2:0.1:0.6;
    cfg.zlim    =   [-2 2];
    cfg.layout  = 'CTF275.lay';
    ft_topoplotTFR(cfg,stat2plot{cnd_f});
    
end