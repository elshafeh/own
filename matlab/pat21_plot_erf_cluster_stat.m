clear;clc;dleiftrip_addpath;

load ../data/yctot/stat/new_bigComputer_pe_sensor_nDT.mat

for cnd_s = 1:length(stat)
    [min_p(cnd_s) , p_val{cnd_s}]         = h_pValSort(stat{cnd_s}) ;
end

for cnd_s = 1:length(stat)
    stat{cnd_s}.mask            = stat{cnd_s}.prob < 0.05;
    stat2plot{cnd_s}.dimord     = stat{cnd_s}.dimord;
    stat2plot{cnd_s}.label      = stat{cnd_s}.label;
    stat2plot{cnd_s}.time       = stat{cnd_s}.time;
    stat2plot{cnd_s}.avg        = stat{cnd_s}.mask .* stat{cnd_s}.stat;
end

lst_cnd = {'RmN','LmN','RmL'};

i  = 0 ;
for cnd_s = 1:length(stat)
    for t = -0.1:0.1:0.5
        i = i + 1;
        subplot(3,7,i)
        cfg         = [];
        cfg.layout  = 'CTF275.lay';
        cfg.xlim    = [t t+0.1];
        cfg.zlim    = [-1 1];
        cfg.comment ='no';
        ft_topoplotER(cfg,stat2plot{cnd_s});
        title([lst_cnd{cnd_s} ' ' num2str(t*1000) 'ms']);
    end
end