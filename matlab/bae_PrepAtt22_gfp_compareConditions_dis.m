clear ; clc ;

patient_list ;
suj_group{1}    = fp_list_meg;
suj_group{2}    = cn_list_meg;

for ngrp = 1:2
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'DIS','fDIS'};
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                tmp{dis_type}                       = data_pe;
                
                clear data_pe data_gfp
                
            end
            
            avg_diff                            = tmp{1};
            avg_diff.avg                        = tmp{1}.avg - tmp{2}.avg;
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            avg_diff_lb                         = ft_timelockbaseline(cfg,avg_diff);
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            avg_diff_lb_gfp                     = ft_globalmeanfield(cfg,avg_diff_lb);
            
            allsuj_data{ngrp}{sb,ncue}          = avg_diff_lb_gfp;
            
        end
        
    end  
end

clearvars -except *_data cond_sub

for ngroup = 1:length(allsuj_data)
    
    ix_test                 = [1 2];
    
    for ntest = 1:size(ix_test,1)
        
        
        cfg                     = [];
        cfg.latency             = [-0.1 0.35];
        cfg.statistic           = 'ft_statfun_depsamplesT';
        cfg.method              = 'montecarlo';
        cfg.correctm            = 'cluster';
        cfg.clusteralpha        = 0.05;
        cfg.clusterstatistic    = 'maxsum';
        cfg.minnbchan           = 0;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.alpha               = 0.025;
        cfg.numrandomization    = 1000;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        nbsuj                   = length(allsuj_data{ngroup});
        [design,~]              =  h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');
        
        cfg.design              = design;
        stat{ngroup,ntest}      = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
        
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end

cond_sub    = {{'V','N'}};
lst_group   = {'Patient','Control'};
ix_test     = [1 2];
i           =  0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        i = i + 1;
        
        subplot(size(stat,1),size(stat,2),i)
        
        cfg             = [];
        cfg.p_threshold = 0.14;
        cfg.lineWidth   = 2;
        cfg.time_limit  = [-0.1 0.35];
        cfg.z_limit     = [0 120];
        cfg.fontSize    = 18;

        gavg1           = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,ix_test(ntest,1)});
        gavg2           = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,ix_test(ntest,2)});
        
        h_plotSingleERFstat(cfg,stat{ngroup,ntest},gavg1,gavg2);
        
        title([lst_group{ngroup} ' min p = ' num2str(round(min_p(ngroup,ntest),5))])
        
        legend(cond_sub{ntest});
        
        set(gca,'fontsize', 18)
        
    end
end