clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/LRNnDT.pe.mat
load ../data/yctot/rt/rt_CnD_adapt.mat

for sb = 1:14
    
    suj_list            = [1:4 8:17];
    suj                 = ['yc' num2str(suj_list(sb))];
    avg                 = ft_timelockgrandaverage([],allsuj{sb,:});
    
    cfg                 = [];
    cfg.baseline        = [-0.2 -0.1];
    avg                 = ft_timelockbaseline(cfg,avg);
    
    list_latency        = [0.05 0.185];
    
    load ../data/yctot/gavg/nDT2RChanList.mat
    
    t       = 1;
    lmt1    = find(round(avg.time,5) == round(list_latency(t,1),5));
    lmt2    = find(round(avg.time,5) == round(list_latency(t,2),5));
    
    for gp_chn  =1:4
        ix                          = h_indx_tf_labels(list_chan{t,gp_chn});
        erf2permute(sb,gp_chn)      = mean(mean(avg.avg(ix,lmt1:lmt2)));
    end
    
    rt2permute(sb,1)    = median(rt_all{sb});
    rt2permute(sb,2)    = mean(rt_all{sb});
    
end

clearvars -except *permute

[rho,p] = corr(erf2permute,rt2permute, 'type', 'Spearman');