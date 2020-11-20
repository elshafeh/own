clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/D123.1.Dis.2.fDis.pe.mat

for sb = 1:size(allsuj,1)
    
    for cnd = 1:size(allsuj,3)
        
        allsuj_GA{sb,cnd}       = allsuj{1,1,1};
        allsuj_GA{sb,cnd}.avg   = allsuj{sb,1,cnd}.avg - allsuj{sb,2,cnd}.avg;
        
        %         cfg                     = [];
        %         cfg.baseline            = [-0.1 0];
        %         allsuj_GA{sb,cnd}       = ft_timelockbaseline(cfg,allsuj_GA{sb,cnd});
        
    end
end

[design,neighbours] = h_create_design_neighbours(14,'meg','a'); clc;

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [-0.1 0.6];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesFunivariate';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.design              = design;
cfg.clustercritval      = 0.05;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
cfg.numrandomization    = 1000;

ifreq = 1:10:100;

for cf = 1:length(ifreq)
    cfg.frequency      = [ifreq(cf) ifreq(cf)+9];
    stat{cf}           = ft_freqstatistics(cfg, allsujGA{:,1},allsujGA{:,2},allsujGA{:,3});
    stat{cf}           = rmfield(stat{cf},'cfg');
end

clearvars -except stat

for cf = 1:length(stat)
        [min_p(cf),p_val{cf}]             = h_pValSort(stat{cf});
        stat2plot{cf}                     = h_plotStat(stat{cf},0.1,'no');
end

anova2plot.freq         = 1:100;
anova2plot.time         = stat2plot{1}.time;
anova2plot.label        = stat2plot{1}.label;
anova2plot.powspctrm    = [];
anova2plot.dimord       = 'chan_freq_time';

for cf = 1:length(stat)
    anova2plot.powspctrm = cat(2,anova2plot.powspctrm,stat2plot{cf}.powspctrm);
end

clearvars -except stat anova2plot min_p p_val;

cfg = [] ; 
cfg.layout = 'CTF275.lay';
cfg.xlim = -0.2:0.1:0.7;
cfg.zlim = [0 1];
ft_topoplotTFR(cfg,anova2plot);

i = 0 ;

for f = 1:10:50
    
    i = i + 1 ;
    
    subplot(3,2,i)
    
    cfg         =   [];
    cfg.ylim    =   [f f+10];
    cfg.zlim    =   [-2 2];
    cfg.layout  = 'CTF275.lay';
    ft_topoplotTFR(cfg,anova2plot);
    
end