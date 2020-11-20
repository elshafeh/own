clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name2               = 'PaperIndex.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrialsMinEvoked10MStep80SlctSorted';
        %         ext_name2               = 'PaperIndex.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrialsMinEvoked10MStep100SlctSorted';
        
        list_ix                 = {'R','L','N'};
        
        for ncue = 1:length(list_ix)
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq                    = ft_freqdescriptives([],freq);
            freq                    = h_transform_freq(freq,{1,2,[3 5],[4 6]},{'vis_paper_L','vis_paper_R','aud_paper_L','aud_paper_R'});
            
            cfg                     = [];
            cfg.baseline            = [-0.6 -0.2];
            cfg.baselinetype        = 'relchange';
            freq                    = ft_freqbaseline(cfg,freq);
            
            freq_list               = [7 15; 7 11; 11 15];
            
            for nfreq = 1:length(freq_list)
                
                y1       = find(round(freq.freq)== round(freq_list(nfreq,1)));
                y2       = find(round(freq.freq)== round(freq_list(nfreq,2)));
                
                pow      = squeeze(mean(freq.powspctrm(:,y1:y2,:),2));
                
                allsuj_data{ngroup}{sb,ncue,nfreq}.dimord   = 'chan_time';
                allsuj_data{ngroup}{sb,ncue,nfreq}.time     = freq.time;
                allsuj_data{ngroup}{sb,ncue,nfreq}.label    = freq.label;
                allsuj_data{ngroup}{sb,ncue,nfreq}.avg      = pow;
                
                clear y1 y2 pow;
                
            end
            
        end
        
    end
end

clearvars -except new_allsuj_data list_ix

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t'); clc;
    
    cfg                     = [];
    
    cfg.latency             = [0.2 1.2];
    
    cfg.neighbours          = neighbours;
    cfg.minnbchan           = 0;
    
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    
    cfg.correctm            = 'cluster';
    
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    list_compare            = [1 2; 1 3; 2 3];
    
    for ntest = 1:size(list_compare,1)
        
        for nfreq = 1:size(allsuj_data{ngroup},3)
            
            stat{ngroup,ntest,nfreq}  = ft_timelockstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1),nfreq}, allsuj_data{ngroup}{:,list_compare(ntest,2),nfreq});
            
        end
        
        list_test{ntest}    = [list_ix{list_compare(ntest,1)} 'v' list_ix{list_compare(ntest,2)}];
        
    end
end

clearvars -except allsuj_data stat list_ix list_test list_compare

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for nfreq = 1:size(stat,3)
            [min_p(ngroup,ntest,nfreq), p_val{ngroup,ntest,nfreq}]      = h_pValSort(stat{ngroup,ntest,nfreq}) ;
        end
    end
end

clearvars -except allsuj_data stat min_p p_val list_ix list_test list_compare

i= 0 ;

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,3)
        
        for nchan = 1:length(stat{1}.label)
            for ntest = 1:size(stat,2)
                
                plimit                  = 0.11;
                
                z_limit                 = [-0.7 0.1];
                
                plt_cfg                 = [];
                plt_cfg.channel         = nchan;
                plt_cfg.p_threshold     = plimit;
                plt_cfg.lineWidth       = 3;
                plt_cfg.time_limit      = [-0.2 2];
                plt_cfg.z_limit         = z_limit;
                plt_cfg.fontSize        = 18;
                
                i  = i + 1;
                
                subplot(4,6,i)
                
                data_avg1 = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,list_compare(ntest,1),nfreq});
                data_avg2 = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,list_compare(ntest,2),nfreq});
                
                h_plotSingleERFstat_selectChannel(plt_cfg,stat{ngroup,ntest,nfreq},data_avg1,data_avg2);
                
                vline(0,'--k');
                vline(1.2,'--k');
                
                lstgroup = {'Old','Young'};
                lstFreq  = {'7t15Hz','7t11Hz','11t15Hz'};
                lstChan  = {'vis_paper_L','vis_paper_R','aud_paper_L','aud_paper_R'};
                
                title([lstgroup{ngroup} ' ' lstChan{nchan} ' ' list_test{ntest} ' ' lstFreq{nfreq}]);
                
                legend({list_ix{list_compare(ntest,1)},list_ix{list_compare(ntest,2)}});
                
            end
        end
    end
end