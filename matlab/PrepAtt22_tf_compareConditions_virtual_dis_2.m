clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

lst_group       = {'old','young'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        lst_dis = {'DIS','fDIS'};
        lst_cue = {'V','N'};
        
        for ncue = 1:length(lst_cue)
            
            for cnd_dis = 1:2
                
                suj                 = suj_list{sb};
                fname_in            = ['../data/' suj '/field/' suj '.' lst_cue{ncue} lst_dis{cnd_dis} '.AgeCommonROI.40t120Hz.m200p600msCov.waveletPOW.40t119Hz.m1000p1000.KeepTrials.MinEvoked.mat'];
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in)
                
                if isfield(freq,'check_trialinfo')
                    freq = rmfield(freq,'check_trialinfo');
                end
                
                freq           = ft_freqdescriptives([],freq);
                freq           = h_transform_freq(freq,{[1 2],[3 4]},{'audL','audR'});
                
                tmp{cnd_dis}   = freq; clear freq
                
            end
            
            cfg                             = [];
            cfg.parameter                   = 'powspctrm';
            cfg.operation                   = 'x1-x2';
            freq                            = ft_math(cfg,tmp{1},tmp{2});
            
            clear tmp
            
            for nchan = 1:length(freq.label)
                allsuj_data{ngroup}{sb,ncue,nchan}            = freq;
                allsuj_data{ngroup}{sb,ncue,nchan}.powspctrm  = freq.powspctrm(nchan,:,:);
                allsuj_data{ngroup}{sb,ncue,nchan}.label      = freq.label(nchan);
            end
            
            clear freq
            
        end
    end
end

clearvars -except allsuj_data

for ngroup = 1:length(allsuj_data)
    
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,~]              = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t'); clc;
    
    cfg                     = [];
    cfg.latency             = [-0.1 0.5];
    cfg.frequency           = [60 100];
    %     cfg.avgoverfreq         = 'yes';
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
    
    list_compare            = [1 2];
    
    i = 0 ;
    
    for nchan = 1:size(allsuj_data{ngroup},3)
        
        i = i + 1;
        
        for ntest = 1:size(list_compare,1)
            
            stat{ngroup,i,ntest}       = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1),nchan}, allsuj_data{ngroup}{:,list_compare(ntest,2),nchan});
            
        end
    end
end

clearvars -except stat allsuj_data ;

for ngroup = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            [min_p(ngroup,nchan,ntest), p_val{ngroup,nchan,ntest}]      = h_pValSort(stat{ngroup,nchan,ntest}) ;
        end
    end
end

for ngroup = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            stat{ngroup,nchan,ntest} = rmfield(stat{ngroup,nchan,ntest},'cfg');
        end
    end
end

clearvars -except allsuj_data stat min_p p_val list_ix

for ngroup = 1:size(stat,1)
    
    figure;
    i = 0 ;
    
    for nchan =  1:size(stat,2)
        for ntest = 1:size(stat,3)
            
            i = i + 1;
            
            plimit                          = 0.05;
            s2plot                          = stat{ngroup,nchan,ntest};
            s2plot.mask                     = s2plot.prob < plimit;
            subplot(size(stat,2),size(stat,3),i)
            
            %             cfg             = [];
            %             cfg.ylim        = [-3 3]; %y axes limits
            %             cfg.linewidth   = 2;
            %             cfg.p_threshold = 0.11; %to handle the mask
            %             h_plotStatAvgOverDimension(cfg,stat{ngroup,nchan,ntest})
            
            cfg                             = [];
            cfg.parameter                   = 'stat';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.colorbar                    = 'no';
            cfg.zlim                        = [-3 3];
            ft_singleplotTFR(cfg,s2plot);
            colormap('jet')
            
        end
    end
end

