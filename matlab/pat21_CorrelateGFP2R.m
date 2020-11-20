clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/LRNnDT.pe.mat	
load ../data/yctot/rt/rt_CnD_adapt.mat

for sb = 1:14
    
    avg                 = ft_timelockgrandaverage([],allsuj{sb,:});
    
    cfg                 = [];
    cfg.baseline        = [-0.1 0];
    avg                 = ft_timelockbaseline(cfg,avg);
    
    cfg                 = [];
    cfg.method          = 'amplitude';
    gfp                 = ft_globalmeanfield(cfg, avg);
    
    list_latency        = [0.05 0.185; 0.185 0.28; 0.28 0.5];
    
    for t = 1:3
        
        lmt1                    = find(round(avg.time,3) == round(list_latency(t,1),3));
        lmt2                    = find(round(avg.time,3) == round(list_latency(t,2),3));
        
        data                    = max(squeeze(gfp.avg(lmt1:lmt2)));
        data2permute(sb,t)      = data;
        
        
    end
    
    rt2permute(sb,1) = mean(rt_all{sb});
    rt2permute(sb,2) = median(rt_all{sb});
end

clearvars -except *2permute

for t = 1:3
    for rt = 1:2      
        [rho(t,rt),p(t,rt)] = corr(data2permute(:,t), rt2permute(:,rt), 'type', 'Spearman');      
    end
end