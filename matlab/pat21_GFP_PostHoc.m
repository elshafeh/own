clear ; clc ; dleiftrip_addpath ;

% load ../data/yctot/gavg/LRNnDT.pe.mat
load ../data/yctot/gavg/new.1N2L3R.CnD.pe.mat

for sb = 1:14
    for cnd = 1:size(allsuj,2)
        
        cfg                 = [];
        cfg.baseline        = [-0.1 0];
        avg                 = ft_timelockbaseline(cfg,allsuj{sb,cnd});
        
        cfg                 = [];
        cfg.method          = 'amplitude';
        gfp                 = ft_globalmeanfield(cfg, avg);
        
        twin                = 0.3;
        tlist               = 0.6:twin:1.2-twin;
        
        for t = 1:length(tlist)
            
            lmt1                = find(round(avg.time,3) == round(tlist(t),3));
            lmt2                = find(round(avg.time,3) == round(tlist(t),3));
            
            data                = mean(squeeze(gfp.avg(lmt1:lmt2)));
            
            data2permute(sb,cnd,t) = data;
            
            
        end
    end
end

clearvars -except data2permute tlist;

for t = 1:size(data2permute,3)
    p_RL(t) = permutation_test(squeeze(data2permute(:,[3 2],t)),10000);
    p_RN(t) = permutation_test(squeeze(data2permute(:,[3 1],t)),10000);
    p_LN(t) = permutation_test(squeeze(data2permute(:,[2 1],t)),10000);
end

lm_p = 0.05 / length(tlist)*3;

plot(tlist,[p_RL;p_RN;p_LN],'LineWidth',3);legend({'RL','RN','LN'});ylim([0 0.1]);