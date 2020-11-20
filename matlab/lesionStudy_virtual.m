clear ; clc ;

patient_list;

suj_group{1}                                = fp_list_meg ;
suj_group{2}                                = cn_list_meg ; clear *list* ;

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        ext_name2               = 'BroadAVMSep.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.MinEvokedAvgTrials';
        
        fname_in                = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        freq                        = h_transform_freq(freq,{[1 2],[3 4],[5 6]},{'Visual Cortex','Auditory Cortex','Motor Cortex'});
        
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj_data{ngroup}{sb,1}   = ft_freqbaseline(cfg,freq);
        
        clc;
        
    end
    
end

clearvars -except allsuj_data list_ix

list_freq                       = [7 11; 11 15];
time_lim                        = [-0.2 2];

for nfreq = 1:size(list_freq,1)
    
    freq_lim                    = list_freq(nfreq,:);
    
    for ncue = 1:size(allsuj_data{1},2)
        
        nsubj                   = size(allsuj_data{1},1);
        
        [~,neighbours]          = h_create_design_neighbours(nsubj,allsuj_data{1}{1},'virt','t'); clc;
        
        cfg                     = [];
        cfg.statistic           = 'indepsamplesT'; cfg.method = 'montecarlo';
        cfg.correctm = 'fdr'; cfg.clusterstatistic = 'maxsum';
        
        cfg.avgoverfreq         = 'yes';
        
        cfg.clusteralpha        = 0.05;
        cfg.tail                = 0; cfg.clustertail         = 0;
        cfg.alpha               = 0.025; cfg.numrandomization    = 1000;
        
        cfg.design              = [ones(1,nsubj) ones(1,nsubj)*2];
        cfg.minnbchan           = 0;
        cfg.neighbours          = neighbours;
        
        cfg.frequency           = freq_lim;
        cfg.latency             = time_lim;
        
        stat{ncue,nfreq}        = ft_freqstatistics(cfg,allsuj_data{2}{:,ncue}, allsuj_data{1}{:,ncue});
        
    end
end

for ncue = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        [min_p(ncue,nfreq),p_val{ncue,nfreq}] = h_pValSort(stat{ncue,nfreq});
    end
end

clearvars -except allsuj_data list_ix stat min_p p_val

figure;
i = 0 ;

for nfreq = 1:size(stat,2)
    for ncue = 1:size(stat,1)
        
        list_freq                           = [7 11; 11 15];
        freq_lim                            = list_freq(nfreq,:);
        time_lim                            = [-0.1 1.2];

        for nchan = 1:length(stat{ncue}.label)
            
            i                               = i + 1 ;
            
            plimit                          = 0.05;
            s2plot                          = stat{ncue,nfreq};
            s2plot.mask                     = s2plot.prob < plimit;
            
            subplot_row                     = 2 ;
            subplot_col                     = 3 ;
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.p_threshold                 = plimit;
            cfg.lineWidth                   = 2;
            cfg.time_limit                  = time_lim;
            cfg.z_limit                     = [-0.35 0.35];
            cfg.avglimit                    = freq_lim;
            cfg.legend                      = {'patient','control'};
            
            subplot(subplot_row,subplot_col,i)
            h_plotSingleTFstat_selectChannel(cfg,s2plot,ft_freqgrandaverage([],allsuj_data{1}{:,ncue}),ft_freqgrandaverage([],allsuj_data{2}{:,ncue}))
            
            title([s2plot.label{nchan}],'FontSize',14)
            
        end
    end
end