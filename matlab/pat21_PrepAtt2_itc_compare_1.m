clear ; clc ;

clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    cnd_list    = {'R','L','N','LplusN','RplusN','LplusR'};
    
    for ncond = 1:length(cnd_list)
        
        load(['../data/tfr/' suj '.' cnd_list{ncond} 'CnD.m1000p2000.1t100Hz.itc.mat']);
        
        allsuj_GA{sb,ncond}                =   itc ;
        allsuj_GA{sb,ncond}.powspctrm      =   itc.itpc;
        allsuj_GA{sb,ncond}                =   rmfield(allsuj_GA{sb,ncond},'itpc');
        allsuj_GA{sb,ncond}                =   rmfield(allsuj_GA{sb,ncond},'itlc');
        allsuj_GA{sb,ncond}                =   rmfield(allsuj_GA{sb,ncond},'trialinfo');
        
        clear itc;
        
    end
    
end

clearvars -except allsuj_GA ;

% new_allsuj_GA = h_calculate_poi(allsuj_GA,1,2,6); allsuj_GA = new_allsuj_GA ; clear new_allsuj_GA;

[design,neighbours]    = h_create_design_neighbours(length(allsuj_GA),allsuj_GA{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
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
% cfg.frequency           = [5 15];
cfg.latency             = [0 1.2];
stat{1}                 = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});

for nstat = 1:length(stat)
    [min_p(nstat),p_val{nstat}] = h_pValSort(stat{nstat});
    stat2plot{nstat}            = h_plotStat(stat{nstat},0.0000000001,0.05);
end

for nstat = 1:length(stat)
    figure;
    for chn = 1:length(stat{nstat}.label)
        subplot(2,1,chn)
        cfg                 = [];
        cfg.channel         = chn;
        cfg.zlim            = [-2 2];
        ft_singleplotTFR(cfg,stat2plot{nstat});
    end
end