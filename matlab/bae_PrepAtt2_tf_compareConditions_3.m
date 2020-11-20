clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

lst_group       = {'allyoung'};

for ngroup = 1:length(lst_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        list_ix                 = {'R','L','NR','NL'};
        
        for cnd = 1:length(list_ix)
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_ix{cnd} cond_main '.AllYungSeparatePlusCombined.50t120Hz.m800p2000msCov.waveletPOW.40t120Hz.m1000p2000.AvgTrials.100Slct.AudLR.MinEvoked.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                                                 = [];
            cfg.baseline                                        = [-0.3 -0.1];
            cfg.baselinetype                                    = 'relchange';
            freq                                                = ft_freqbaseline(cfg,freq);
            
            for nchan = 1:length(freq.label)
                allsuj_data{ngroup}{sb,cnd,nchan}               = freq;
                allsuj_data{ngroup}{sb,cnd,nchan}.powspctrm     = freq.powspctrm(nchan,:,:);
                allsuj_data{ngroup}{sb,cnd,nchan}.label         = freq.label(nchan);
            end
            
            clear freq
            
        end
    end
end

clearvars -except allsuj_data big_freq

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,~]              = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t'); clc;
    
    cfg                     = [];
    
    cfg.latency             = [1.4 1.8];
    cfg.frequency           = [60 100];
    cfg.avgoverfreq         = 'yes';
    %     cfg.avgovertime         = 'yes';
    
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    cfg.correctm            = 'fdr';
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    cfg.minnbchan           = 0;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    list_compare            = [1 3; 2 4; 1 2];
    
    i = 0 ;
    
    for nchan = 1:size(allsuj_data{ngroup},3)
        
        i = i + 1;
        
        for ntest = 1:size(list_compare,1)
            stat{ngroup,i,ntest}     = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1),nchan}, allsuj_data{ngroup}{:,list_compare(ntest,2),nchan});
        end
    end
end

for ngroup = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            [min_p(ngroup,nchan,ntest), p_val{ngroup,nchan,ntest}]      = h_pValSort(stat{ngroup,nchan,ntest}) ;
        end
    end
end

list_test   = {'R.NR','L.NL','R.L'};
list_group  = {'allyoung'};
plimit  = 0.2;

for ngroup = 1:size(stat,1)
    
    figure;
    
    i       = 0 ;
    
    for ntest = 1:size(stat,3)
        for nchan = size(stat,2):-1:1
            
            i = i + 1;
            
            zlimit                          = 2;
            
            s2plot                          = stat{ngroup,nchan,ntest};
            s2plot.mask                     = s2plot.prob < plimit;
            
            subplot(3,2,i)
            
            %             cfg                             = [];
            %             %             cfg.xlim                        = [0.5 1.1];
            %             %             cfg.ylim                        = list_freq{nfreq};
            %             cfg.parameter                   = 'stat';
            %             cfg.maskparameter               = 'mask';
            %             cfg.colorbar                    = 'no';
            %             cfg.maskstyle                   = 'outline';
            %             cfg.zlim                        = [-5 5];
            %             ft_singleplotTFR(cfg,s2plot);
            
            cfg             = [];
            cfg.ylim        = [-zlimit zlimit];
            cfg.linewidth   = 1;
            cfg.p_threshold = plimit;
            h_plotStatAvgOverDimension(cfg,s2plot);
            
            title([list_group{ngroup} '.' list_test{ntest} '.' s2plot.label{1} ' p limit at ' num2str(plimit)]);
            
            colormap('jet')
            
        end
    end
end