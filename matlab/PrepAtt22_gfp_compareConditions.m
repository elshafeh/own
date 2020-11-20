
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_list,~]                  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}                    = suj_list(2:22);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        cond_main           = 'nDT';
        
        cond_sub            = {'Hi','Lo'};
        
        dir_data            = '../data/pitch_data/';
        
        for ncue = 1:length(cond_sub)
            
            if strcmp(cond_main,'CnD')
                fname_in            = [dir_data  suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
            else
                fname_in            = [dir_data  suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            end
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe);
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            data_gfp                            = ft_globalmeanfield(cfg,data_pe);
            
            allsuj_data{ngrp}{sb,ncue}          = data_gfp;
            
            clear data_pe
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub lst_group;

for ngroup = 1:length(allsuj_data)
    
    ix_test                     = [1 2];
    
    for ntest = 1:size(ix_test,1)
        
        
        cfg                     = [];
        
        cfg.latency             = [-0.1 0.6];
        
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

lst_group = {'Young Cohort n=21'};
i         =  0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        i = i + 1;
        
        subplot(1,1,i)
        
        cfg                 = [];
        cfg.p_threshold     = 0.05;
        cfg.lineWidth       = 3;
        cfg.time_limit      = [-0.1 0.6];
        cfg.z_limit         = [0 100];
        cfg.fontSize        = 18;
        
        h_plotSingleERFstat(cfg,stat{ngroup,ntest},gavg_data{ngroup,ix_test(ntest,1)},gavg_data{ngroup,ix_test(ntest,2)});
        
        legend({cond_sub{ix_test(ntest,1)},cond_sub{ix_test(ntest,2)}})
        
        title(lst_group{ngroup})
        set(gca,'fontsize', 18)
        
    end
end