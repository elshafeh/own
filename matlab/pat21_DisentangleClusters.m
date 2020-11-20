clear ; clc ; close all ; dleiftrip_addpath ;

load ../data/yctot/stat/ActvBaseline4Neigh7t15Hz200t2000ms.mat

[min_p,p_val] = h_pValSort(stat);

cluster{1}      = h_plotStat2(stat,0.006,0.008);    % positive 
cluster{2}      = h_plotStat2(stat,0.001,0.003);    % neg 1
cluster{3}      = h_plotStat2(stat,0.00001,0.0015); % neg 2
cluster{4}      = h_plotStat(stat,0.05,'no');       % total

f_list = 7:15;
t_list = 0.2:0.2:2;

for c = 1:3
    
    figure;
    
    for f = 1:length(f_list)
        
        subplot(3,3,f)
        
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.ylim        = [f_list(f) f_list(f)];
        cfg.zlim        = [-1.5 1.5];
        ft_topoplotTFR(cfg,cluster{c});
        
    end
    
    figure;
    
    for t = 1:length(t_list)
        
        subplot(2,5,t)
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.xlim        = [t_list(t) t_list(t)+0.2] ;
        cfg.zlim        = [-1.5 1.5];
        ft_topoplotTFR(cfg,cluster{c});
        
    end
    
    clc; 
    
end

