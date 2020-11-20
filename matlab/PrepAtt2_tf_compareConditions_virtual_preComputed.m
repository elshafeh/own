clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        
        cond_main                   = 'DT';
        ext_name                    = 'BroadAud5perc.50t110Hz.m1200p1000msCov.waveletPOW.50t109Hz.m2000p2000.MinEvokedAvgTrials';
        list_ix_cue                 = {'n',''};
        
        for ncue = 1:length(list_ix_cue)
            
            fname_in                = ['../data/DT_data/' suj '.' list_ix_cue{ncue} cond_main '.' ext_name '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                     = [];
            cfg.baseline            = [-1.6 -1.4];
            cfg.baselinetype        = 'relchange';
            freq                    = ft_freqbaseline(cfg,freq);
            
            allsuj_data{ngroup}{sb,ncue} = freq;
            
        end
        
        %         clc;
        
        %         list_to_subtract                = [1 3; 2 4; 1 5; 2 5];
        %         index_cue                       = 5;
        %
        %         for nadd = 1:length(list_to_subtract)
        %
        %             allsuj_data{ngroup}{sb,index_cue+nadd} = allsuj_data{ngroup}{sb,list_to_subtract(nadd,1)};
        %
        %             pow                                    = allsuj_data{ngroup}{sb,list_to_subtract(nadd,1)}.powspctrm - allsuj_data{ngroup}{sb,list_to_subtract(nadd,2)}.powspctrm ;
        %
        %             list_ix_cue{index_cue+nadd}            = [list_ix_cue{list_to_subtract(nadd,1)} 'm' list_ix_cue{list_to_subtract(nadd,2)}];
        %
        %         end
        
    end
end

clearvars -except allsuj_data list_ix_cue

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t'); clc;
    
    cfg                     = [];
    
    cfg.latency             = [-1 1];
    cfg.frequency           = [50 110];
    
    cfg.neighbours          = neighbours;
    cfg.minnbchan           = 0;
    
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    
    cfg.correctm            = 'fdr';
    
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;

    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    list_compare            = [1 2];
    
    for ntest = 1:size(list_compare,1)
        
        stat{ngroup,ntest}  = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1)}, allsuj_data{ngroup}{:,list_compare(ntest,2)});
        list_test{ntest}    = [list_ix_cue{list_compare(ntest,1)} 'v' list_ix_cue{list_compare(ntest,2)}];
        
    end
end

clearvars -except allsuj_data stat list_ix list_test list_ix_cue

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest), p_val{ngroup,ntest}]      = h_pValSort(stat{ngroup,ntest}) ;
    end
end

clearvars -except allsuj_data stat min_p p_val list_ix list_test

i           = 0 ;
plimit      = 0.1;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        s2plot                          = stat{ngroup,ntest};
        s2plot.mask                     = s2plot.prob < plimit;
        
        for nchan = 1:length(s2plot.label)
            
            i = i + 1;
            
            subplot(2,1,i)
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.parameter                   = 'stat';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.colorbar                    = 'no';
            cfg.zlim                        = [-3 3];
            ft_singleplotTFR(cfg,s2plot);
            
            lstgroup = {'Allyoung'};
            
            title([lstgroup{ngroup} ' ' s2plot.label{nchan} ' ' list_test{ntest} ' ' num2str(min_p(ngroup,ntest))]);
            
        end
    end
end