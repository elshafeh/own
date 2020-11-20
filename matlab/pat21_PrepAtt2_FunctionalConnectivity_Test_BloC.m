clear ; clc ; dleiftrip_addpath ; close all;

for ix_j = 1:3
    
    for t = 1:3
        
        
        for sb = 1:14
            
            suj_list        = [1:4 8:17];
            suj             = ['yc' num2str(suj_list(sb))];
            
            load(['../data/tfr/' suj '.Soma.CohCohImagPLV.AuditoryWithIPSFEF.Bloc' num2str(t) '.mat'])
            
            allsuj{sb,t}                       = [];
            allsuj{sb,t}.freq                  = suj_coh{ix_j}.freq;
            allsuj{sb,t}.label                 = suj_coh{ix_j}.label;
            allsuj{sb,t}.time                  = 1:length(suj_coh{ix_j}.label);
            allsuj{sb,t}.dimord                = 'chan_time_freq';
            allsuj{sb,t}.powspctrm             = suj_coh{ix_j}.cohspctrm;
            
            clear suj_coh ;
            
        end
        
    end
    
    [design,neighbours]     = h_create_design_neighbours(length(allsuj),allsuj{1,1},'virt','t');
    
    cfg                     = [];
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    cfg.correctm            = 'fdr';
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    cfg.minnbchan           = 0;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.neighbours          = neighbours;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    stat{1} = ft_freqstatistics(cfg,allsuj{:,2},allsuj{:,1});
    stat{2} = ft_freqstatistics(cfg,allsuj{:,3},allsuj{:,1});
    stat{3} = ft_freqstatistics(cfg,allsuj{:,3},allsuj{:,2});
    
    
    for cnds = 1:3
        coh2plot{cnds} = h_stat2coh(stat{cnds},0.000000000000001,0.05);
        %         coh2plot{cnds}.cohspctrm(coh2plot{cnds}.cohspctrm>0)=0;
    end
    
    
    figure;
    cfg             = [];
    cfg.ylim        = [0 6];
    cfg.xlim        = [5 15];
    ft_connectivityplot(cfg,coh2plot{:});
    
end