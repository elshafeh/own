clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name1               = '1t20Hz';
        ext_name2               = 'broadAreas.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrials';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
                
        list_ix_cue        = {2,1,0,0,0};
        list_ix_tar        = {[2 4],[1 3],[2 4],[1 3],1:4};
        list_ix_dis        = {0,0,0,0,0};
        list_ix            = {'R','L','NR','NL','N'};
                
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
            cfg.channel                 = [7 8];
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
            %             cfg                         = [];
            %             cfg.baseline                = [-0.6 -0.2];
            %             cfg.baselinetype            = 'relchange';
            %             new_freq                    = ft_freqbaseline(cfg,new_freq);
            
            audL                        = new_freq.powspctrm(1,:,:);
            audR                        = new_freq.powspctrm(2,:,:);
            lIdx                        = (audR-audL) ./ ((audR+audL)/2);
            
            allsuj_data{ngroup}{sb,cnd}             = new_freq;
            allsuj_data{ngroup}{sb,cnd}.label       = {'LatIndex'};
            allsuj_data{ngroup}{sb,cnd}.powspctrm   = lIdx;
            
            clear lIdx audR audL
            
        end
        
        clc;
        
        freq_list   = [7 11; 11 15; 7 15];
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nfreq = 1:length(freq_list)
                
                y1       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(freq_list(nfreq,1)));
                y2       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(freq_list(nfreq,2)));
                
                pow      = squeeze(mean(allsuj_data{ngroup}{sb,ncue}.powspctrm(:,y1:y2,:),2));
                
                new_allsuj_data{ngroup}{sb,ncue,nfreq}.dimord   = 'chan_time';
                new_allsuj_data{ngroup}{sb,ncue,nfreq}.time     = allsuj_data{ngroup}{sb,ncue}.time;
                new_allsuj_data{ngroup}{sb,ncue,nfreq}.label    = allsuj_data{ngroup}{sb,ncue}.label;
                new_allsuj_data{ngroup}{sb,ncue,nfreq}.avg      = pow';
                
                clear y1 y2 pow;
                
            end
        end
    end
end

clearvars -except new_allsuj_data list_ix

allsuj_data = new_allsuj_data ; clear new_allsuj_data ;

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t'); clc;
    
    cfg                     = [];
    
    cfg.latency             = [0.6 1.1];
    
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
    
    list_compare            = [1 3; 2 4;1 2; 3 4; 1 5; 2 5]; %; 6 7; 8 9];
    
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

for ngroup = 1:size(stat,1)
    for nchan = 1:length(stat{1}.label)
        
        figure ;
        i= 0 ;
        for nfreq = 1:size(stat,3)
            
            for ntest = 1:size(stat,2)
                plimit                  = 0.2;
                
                z_limit                 = [-0.3 0.3];
                
                plt_cfg                 = [];
                plt_cfg.channel         = nchan;
                plt_cfg.p_threshold     = plimit;
                plt_cfg.lineWidth       = 3;
                plt_cfg.time_limit      = [-0.2 1.2];
                plt_cfg.z_limit         = z_limit;
                plt_cfg.fontSize        = 18;
                
                i  = i + 1;
                subplot(3,6,i)
                
                data_avg1 = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,list_compare(ntest,1),nfreq});
                data_avg2 = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,list_compare(ntest,2),nfreq});
                
                h_plotSingleERFstat_selectChannel(plt_cfg,stat{ngroup,ntest,nfreq},data_avg1,data_avg2);
                
                lstgroup = {'Allyoung'};
                
                title([lstgroup{ngroup} ' ' stat{ngroup,ntest,nfreq}.label{nchan} ' ' list_test{ntest}]);
                
                legend({list_ix{list_compare(ntest,1)},list_ix{list_compare(ntest,2)}});
                
            end
        end
    end
end