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
        list_ix            = {'R','L','N'};
                
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
            cfg.channel                 = [7 8];
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
            audL                        = new_freq.powspctrm(1,:,:);
            audR                        = new_freq.powspctrm(2,:,:);
            lIdx                        = (audR-audL) ./ ((audR+audR)/2);
            
            allsuj_data{ngroup}{sb,cnd}             = new_freq;
            allsuj_data{ngroup}{sb,cnd}.label       = {'LatIndex'};
            allsuj_data{ngroup}{sb,cnd}.powspctrm   = lIdx;
            
            clear lIdx audR audL
            
        end
        
        clc;
        
        time_list   = [0.6 1; 0.6 1.1];
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for ntime = 1:length(time_list)
                
                x1       = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(time_list(ntime,1),2));
                x2       = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(time_list(ntime,2),2));
                
                pow      = squeeze(mean(allsuj_data{ngroup}{sb,ncue}.powspctrm(:,:,x1:x2),3));
                
                new_allsuj_data{ngroup}{sb,ncue,ntime}.dimord   = 'chan_time';
                new_allsuj_data{ngroup}{sb,ncue,ntime}.time     = allsuj_data{ngroup}{sb,ncue}.freq;
                new_allsuj_data{ngroup}{sb,ncue,ntime}.label    = allsuj_data{ngroup}{sb,ncue}.label;
                new_allsuj_data{ngroup}{sb,ncue,ntime}.avg      = pow;
                
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
    
    cfg.latency             = [5 15];
    
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
    
    list_compare            = [1 2 ; 1 3 ; 2 3];
    
    for ntest = 1:size(list_compare,1)
        
        for ntime = 1:size(allsuj_data{ngroup},3)
            
            stat{ngroup,ntest,ntime}  = ft_timelockstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1),ntime}, allsuj_data{ngroup}{:,list_compare(ntest,2),ntime});
            
        end
        
        list_test{ntest}    = [list_ix{list_compare(ntest,1)} 'v' list_ix{list_compare(ntest,2)}];
        
    end
end

clearvars -except allsuj_data stat list_ix list_test list_compare

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            [min_p(ngroup,ntest,ntime), p_val{ngroup,ntest,ntime}]      = h_pValSort(stat{ngroup,ntest,ntime}) ;
        end
    end
end

clearvars -except allsuj_data stat min_p p_val list_ix list_test list_compare

for ngroup = 1:size(stat,1)
    for nchan = 1:length(stat{1}.label)
        
        figure ;
        i= 0 ;
        for ntime = 1:size(stat,3)
            
            for ntest = 1:size(stat,2)
                
                plimit                  = 0.2;
                
                z_limit                 = [-0.3 0.3];
                
                plt_cfg                 = [];
                plt_cfg.channel         = nchan;
                plt_cfg.p_threshold     = plimit;
                plt_cfg.lineWidth       = 3;
                plt_cfg.time_limit      = [5 15];
                plt_cfg.z_limit         = z_limit;
                plt_cfg.fontSize        = 18;
                
                i  = i + 1;
                subplot(size(stat,3),size(stat,2),i)
                
                data_avg1 = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,list_compare(ntest,1),ntime});
                data_avg2 = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,list_compare(ntest,2),ntime});
                
                h_plotSingleERFstat_selectChannel(plt_cfg,stat{ngroup,ntest,ntime},data_avg1,data_avg2);
                
                lstgroup = {'Allyoung'};
                
                title([lstgroup{ngroup} ' ' stat{ngroup,ntest,ntime}.label{nchan} ' ' list_test{ntest}]);
                
                legend({list_ix{list_compare(ntest,1)},list_ix{list_compare(ntest,2)}});
                
            end
        end
    end
end