clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/nDTwavStat4.3.neigh.mat

for cfreq = 1:5
    for cbsl = 1
        
        [min_p(cbsl,cfreq), p_val{cbsl,cfreq}]      = h_pValSort(stat{cbsl,cfreq}) ;
        stat2plot{cbsl,cfreq}                       = h_plotStat(stat{cbsl,cfreq},0.05);
        
        list_bsl  = {'preTar','preCue'};
        list_freq = {'theta','alpha','beta','low gamma','high gamma'};
        
        figure;
        cfg         =   [];
        cfg.xlim    =   0:0.05:0.6;
        cfg.zlim    =   [-3 3];
        cfg.layout  = 'CTF275.lay';
        ft_topoplotTFR(cfg,stat2plot{cbsl,cfreq});
        title([list_bsl{cbsl} ' ' list_freq{cfreq}])
        
    end
end

cnd_bsl     = 1 ;
cnd_stat    = 5 ; 
figure;

i = 0 ;

for f = stat{1,5}.freq(1):5:stat{1,5}.freq(end)
    
    i = i + 1 ;
    subplot(3,3,i)
    cfg         =   [];
    cfg.xlim    =   [0.35 0.55];
    cfg.ylim    =   [f f+5];        
    cfg.zlim    =   [-2 2];
    cfg.layout  = 'CTF275.lay';
    ft_topoplotTFR(cfg,stat2plot{cnd_bsl,cnd_stat});
    
end