clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue            = {'1','2'};
        
        for ncue = 1:length(list_ix_cue)
            
            lst_dis = {'fDIS','DIS'};
            
            for cnd_dis = 1:2
                
                suj                 = suj_list{sb};
                
                fname_in       = ['../data/' suj '/field/' suj '.' list_ix_cue{ncue} lst_dis{cnd_dis} '.AudBroadSchaefFront.50t120Hz.m200p800msCov.waveletPOW.50t120Hz.m1000p1000.AvgTrialsMinEvoked10MStep.mat'];

                fprintf('Loading %s\n',fname_in);
                
                load(fname_in)
                
                if isfield(freq,'check_trialinfo')
                    freq = rmfield(freq,'check_trialinfo');
                end
                
                tmp{cnd_dis}        = freq; clear freq ;
                
            end
            
            allsuj_data{ngroup}{sb,ncue}            = tmp{2} ;
            allsuj_data{ngroup}{sb,ncue}.powspctrm  = tmp{2}.powspctrm - tmp{1}.powspctrm ;
            
        end
    end
end

clearvars -except allsuj_* ;

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t'); clc;
    
    cfg                     = [];
    cfg.frequency           = [60 100];
    
    cfg.avgoverfreq         = 'no';
    
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
    
    list_compare            = [1 2];
    list_latency            = [0.1 0.35];
    
    for ntest = 1:size(list_compare,1)
        
        cfg.latency         = list_latency(ntest,:);
        stat{ngroup,ntest}  = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1)}, allsuj_data{ngroup}{:,list_compare(ntest,2)});
        
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest), p_val{ngroup,ntest}]      = h_pValSort(stat{ngroup,ntest}) ;
    end
end

i= 0 ;

list_test = {'1v2'}; %{'VvN','V1vN1','V2vN2'};

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for nchan = 1:length(stat{ngroup,ntest}.label)
            
            s2plot.mask                    = stat{ngroup,ntest}.mask(nchan,:,:);
            s2plot.stat                    = stat{ngroup,ntest}.stat(nchan,:,:);
            s2plot.prob                    = stat{ngroup,ntest}.prob(nchan,:,:);
            s2plot.freq                    = stat{ngroup,ntest}.freq;
            s2plot.time                    = stat{ngroup,ntest}.time;
            s2plot.dimord                  = stat{ngroup,ntest}.dimord;
            s2plot.label                   = stat{ngroup,ntest}.label(nchan);
            
            plimit                          = 0.2;
            s2plot                          = stat{ngroup,ntest};
            s2plot.mask                     = s2plot.prob < plimit;
            
            if min(unique(s2plot.prob(nchan,:,:))) < plimit
                
                %                 i = i + 1;
                figure;
                %                     subplot(2,4,i);
                
                plot(s2plot.time,squeeze(s2plot.stat(nchan,:,:) .* s2plot.mask(nchan,:,:)));
                ylim([-5 5])
                
                cfg                             = [];
                cfg.channel                     = nchan;
                cfg.parameter                   = 'stat';
                cfg.maskparameter               = 'mask';
                cfg.maskstyle                   = 'outline';
                cfg.colorbar                    = 'no';
                cfg.zlim                        = [-3 3];
                ft_singleplotTFR(cfg,s2plot);
                colormap(redblue)
                
                title([s2plot.label{nchan} list_test{ntest} ' ' num2str(min(unique(s2plot.prob(nchan,:,:))))]);
                
            end
        end
    end
end