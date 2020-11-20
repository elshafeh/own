clear ; clc ;

patient_list ;
suj_group{1}    = fp_list_eeg;
suj_group{2}    = cn_list_eeg;

for ngrp = 1:2
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT.eeg';
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            if strcmp(cond_main,'CnD.eeg')
                fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
            else
                fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            end
            
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

for ngroup = 1:length(allsuj_data)
    
    ix_test                 = [1 2];
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t'); clc;
    
    for ntest = 1:size(ix_test,1)
        
        
        cfg                     = [];
        cfg.latency             = [-0.1 0.5];
        cfg.statistic           = 'ft_statfun_depsamplesT';
        cfg.method              = 'montecarlo';
        cfg.correctm            = 'cluster';
        cfg.clusteralpha        = 0.05;
        cfg.clusterstatistic    = 'maxsum';
        
        cfg.minnbchan           = 0;
        cfg.neighbours          = neighbours;
        
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.alpha               = 0.025;
        cfg.numrandomization    = 1000;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        cfg.design              = design;
        
        stat{ngroup,ntest}      = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end

ix_test   = [1 2];
cond_sub  = {'Inf nDT','Unf nDT'};
lst_group = {'Fpatient','Fcontrol'};

figure;
i = 0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        
        for nchan = 1:length(stat{ngroup,ntest}.label)
            
            i = i + 1;
            subplot(2,7,i)
            
            cfg                 = [];
            cfg.channel         = nchan;
            cfg.p_threshold     = 0.11;
            cfg.lineWidth       = 3;
            cfg.time_limit      = [-.1 .5];
            cfg.z_limit         = [-10 10];
            cfg.fontSize        = 18;
            
            h_plotSingleERFstat_selectChannel(cfg,stat{ngroup,ntest},gavg_data{ngroup,ix_test(ntest,1)},gavg_data{ngroup,ix_test(ntest,2)});
            
            legend({cond_sub{ix_test(ntest,1)},cond_sub{ix_test(ntest,2)}})
            title([lst_group{ngroup} ' ' stat{ngroup,ntest}.label{nchan}])
            
        end
    end
end