clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]  = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');

suj_group{1}    = allsuj(2:end,1);
suj_group{2}    = allsuj(2:end,2);

lst_group       = {'Old','Young'};

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT.eeg';
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe);
            
            for nchan = 1:5
                
                cfg                                 = [];
                cfg.channel                         = nchan;
                allsuj_data{ngrp}{sb,ncue,nchan}    = ft_selectdata(cfg,data_pe);
                
            end
            
            clear data_pe
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        for nchan = 1:size(allsuj_data{ngrp},3)
            gavg_data{ngrp,ncue,nchan} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue,nchan});
        end
    end
end

clearvars -except *_data cond_sub lst_group;

for ngroup = 1:length(allsuj_data)
    
    ix_test                 = [1 2];
    
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
        [design,~]              = h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');
        
        cfg.design              = design;
        
        for nchan = 1:size(allsuj_data{ngroup},3)
            stat{ngroup,ntest,nchan}      = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1),nchan}, allsuj_data{ngroup}{:,ix_test(ntest,2),nchan});
        end
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for nchan = 1:size(stat,3)
            [min_p(ngroup,ntest,nchan),p_val{ngroup,ntest,nchan}]           = h_pValSort(stat{ngroup,ntest,nchan}) ;
        end
    end
end

ix_test   = [1 2];
cond_sub  = {'Inf','Unf'};
lst_group = {'Old','Young'};
i         =  0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for nchan = 1:size(stat,3)
            
            
            i = i + 1;
            
            subplot(2,5,i)
            
            cfg                 = [];
            cfg.p_threshold     = 0.11;
            cfg.lineWidth       = 3;
            cfg.time_limit      = [-0.1 0.6];
            cfg.z_limit         = [-10 10];
            cfg.fontSize        = 18;
            
            h_plotSingleERFstat(cfg,stat{ngroup,ntest,nchan},gavg_data{ngroup,ix_test(ntest,1),nchan},gavg_data{ngroup,ix_test(ntest,2),nchan});
            
            legend({cond_sub{ix_test(ntest,1)},cond_sub{ix_test(ntest,2)}})
            title([lst_group{ngroup} '.' stat{ngroup,ntest,nchan}.label])
            
            set(gca,'fontsize', 18)
            
        end
    end
end