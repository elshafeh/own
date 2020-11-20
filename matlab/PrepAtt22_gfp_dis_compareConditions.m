clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'DIS','fDIS'};
        cond_sub            = {'V','N','V1','N1'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                %                 cfg                                 = [];
                %                 cfg.baseline                        = [-0.1 0];
                %                 data_pe                             = ft_timelockbaseline(cfg,data_pe);
                
                cfg                                 = [];
                cfg.method                          = 'amplitude';
                data_gfp                            = ft_globalmeanfield(cfg,data_pe);
                
                tmp{dis_type}                       = data_gfp;
                
                clear data_pe data_gfp
                
            end
            
            cfg                                 = [];
            cfg.parameter                       = 'avg';
            cfg.operation                       = 'x1-x2';
            allsuj_data{ngrp}{sb,ncue}          = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
            
            
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub

for ngroup = 1:length(allsuj_data)
    
    ix_test                 = [1 2; 3 4];
    
    for ntest = 1:size(ix_test,1)
        
        
        cfg                     = [];
        cfg.latency             = [-0.1 0.7];
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


% load ../data_fieldtrip/stat/gfp_DIS_123OldYoungAllYoung_VN.mat
% load ../data_fieldtrip/stat/gfp_DIS_123OldYoungAllYoung_VN.V1N1.V2N2.mat

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end

cond_sub    = {{'V','N'},{'V1','N1'}};
lst_group   = {'old','young'};
ix_test     = [1 2; 3 4];
i           =  0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        i = i + 1;
        
        subplot(size(stat,1),size(stat,2),i)
        
        cfg             = [];
        cfg.p_threshold = 0.14;
        cfg.lineWidth   = 2;
        cfg.time_limit  = [0 0.7];
        cfg.z_limit     = [0 100];
        cfg.fontSize    = 18;

        h_plotSingleERFstat(cfg,stat{ngroup,ntest},gavg_data{ngroup,ix_test(ntest,1)},gavg_data{ngroup,ix_test(ntest,2)});
        
        title([lst_group{ngroup} ' min p = ' num2str(round(min_p(ngroup,ntest),5))])
        
        legend(cond_sub{ntest});
        
        set(gca,'fontsize', 18)
        
    end
end