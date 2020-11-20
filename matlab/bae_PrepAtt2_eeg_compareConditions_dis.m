clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

patient_list ;
suj_group{1}    = fp_list_eeg;
suj_group{2}    = cn_list_eeg;

for ngrp = 1:2
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        list_cue        = {'V','N'};
        
        for ncue  = 1:length(list_cue)
            
            i               = 0 ;

            for ndis = {'DIS.eeg','fDIS.eeg'}
                
                fname_in        = ['../data/' suj '/field/' suj '.' list_cue{ncue} ndis{:} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                cfg             = [];
                cfg.baseline    = [-0.1 0];
                data_pe         = ft_timelockbaseline(cfg,data_pe);
                
                i               = i + 1;
                tmp{i}          = data_pe;
                
            end
            
            data_pe                                 = tmp{1};
            data_pe.avg                             = tmp{1}.avg - tmp{2}.avg; clear tmp ; 

            allsuj_data{ngrp}{sb,ncue}              = data_pe;
            
        end

        clear data_pe 
        
    end
end

clearvars -except *_data ; clc ; 

for ngroup = 1:length(allsuj_data)
    
    ix_test                     = [1 2];
    
    for ntest = 1:size(ix_test,1)
        
        nbsuj                   = length(allsuj_data{ngroup});
        [design,neighbours]     =  h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');
        
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
        cfg.neighbours          = neighbours;
        
        cfg.design              = design;
        stat{ngroup,ntest}      = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
        
    end
end


for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end

i = 0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        s_to_plot = stat{ngroup,ntest};
        
        for nchan = 1:length(s_to_plot.label)
            
            i = i + 1;
            
            subplot(2,7,i)
            
            cfg                     = [];
            cfg.channel             = nchan;
            cfg.p_threshold         = 0.05;
            cfg.lineWidth           = 3;
            cfg.time_limit          = [-0.1 0.6];
            cfg.z_limit             = [-10 10];
            cfg.fontSize            = 18;
            
            h_plotSingleERFstat_selectChannel(cfg,s_to_plot,ft_timelockgrandaverage([],allsuj_data{ngroup}{:,ix_test(ntest,1)}), ...
                ft_timelockgrandaverage([],allsuj_data{ngroup}{:,ix_test(ntest,2)}));
            
            title(s_to_plot.label{nchan})
            legend({'VDIS','NDIS'})
            
        end     
    end
end