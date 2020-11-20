clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');
[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}([2:9 11:22]);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT.eeg';
        cond_sub            = {'V','N','L','R','NL','NR'};
        
        for ncue = 1:length(cond_sub)
            
            fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe);
            
            allsuj_data{ngrp}{sb,ncue}          = data_pe;
            
            clear data_pe
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
end

clearvars -except *_data cond_sub lst_group;

list_test_done          = {};

for ngroup = 1:length(allsuj_data)
    
    ix_test                 = [1 2; 4 6; 3 5; 4 3]; % V vs N, R vs NR, L vs NL, R vs L
    
    for ntest = 1:size(ix_test,1)
        
        
        nbsuj                   = length(allsuj_data{ngroup});
        [design,neighbours]      = h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');
        
        cfg                     = [];
        cfg.latency             = [0 0.5];
        cfg.statistic           = 'ft_statfun_depsamplesT';
        cfg.method              = 'montecarlo';
        cfg.correctm            = 'cluster';
        cfg.clusteralpha        = 0.05;
        cfg.minnbchan           = 0;
        cfg.neighbours          = neighbours;
        cfg.clusterstatistic    = 'maxsum';
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.alpha               = 0.025;
        cfg.numrandomization    = 1000;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        cfg.design              = design;
        
        stat{ngroup,ntest}      = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
        list_test_done{ntest}   = [cond_sub{ix_test(ntest,1)} '.versus.' cond_sub{ix_test(ntest,2)}];
        
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end


% Results

i         =  0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for nchan = 1:length(stat{ngroup,ntest}.label)
            
            i = i + 1;
            
            subplot(4,7,i)
            
            cfg                 = [];
            cfg.p_threshold     = 0.05;
            cfg.lineWidth       = 3;
            cfg.channel         = nchan;
            cfg.time_limit      = [0 0.5];
            cfg.z_limit         = [-10 10];
            cfg.fontSize        = 18;
            
            h_plotSingleERFstat(cfg,stat{ngroup,ntest},gavg_data{ngroup,ix_test(ntest,1)},gavg_data{ngroup,ix_test(ntest,2)});
            
            legend({cond_sub{ix_test(ntest,1)},cond_sub{ix_test(ntest,2)}})
            
            title([stat{ngroup,ntest}.label{nchan} '.' list_test_done{ntest} ' min p = ' num2str(round(min_p(ngroup,ntest),5))])
            
            %             set(gca,'fontsize', 18)
            
        end
    end
end


clearvars -except stat gavg_data list_test_done ix_test
save 'cluster_based_permutations_young_dis_eeg_channels.mat'