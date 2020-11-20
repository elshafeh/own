clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/Concat_DisfDis.pe.mat ;
load ../data/yctot/rt/rt_dis_per_delay.mat ;

for sb = 1:14
    
    cfg                 = [];
    cfg.parameter       = 'avg';
    cfg.operation       = 'subtract';
    avg                 = ft_math(cfg,allsuj{sb,1},allsuj{sb,2});
    
    %     cfg                 = [];
    %     cfg.baseline        = [-0.1 0];
    %     avg                 = ft_timelockbaseline(cfg,avg);
    
    cfg                 = [];
    cfg.method          = 'amplitude';
    gfp                 = ft_globalmeanfield(cfg, avg); clear avg ;
    
    list_latency        = [0.06 0.16; 0.16 0.37; 0.37 0.47; 0.47 0.55];
    
    for t = 1:size(list_latency,1)
        lmt1                    = find(round(gfp.time,3) == round(list_latency(t,1),3));
        lmt2                    = find(round(gfp.time,3) == round(list_latency(t,2),3));
        data                    = max(squeeze(gfp.avg(lmt1:lmt2)));
        data2permute(sb,t)      = data;
    end
    
    rt2permute(sb,1) = mean([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    rt2permute(sb,2) = median([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    
end

clearvars -except *2permute

for t = 1:4
    for rt = 1:2      
        [rho(t,rt),p(t,rt)] = corr(data2permute(:,t), rt2permute(:,rt), 'type', 'Spearman');      
    end
end

mask    = p < 0.1 ;
nwRho   = mask .* rho ;