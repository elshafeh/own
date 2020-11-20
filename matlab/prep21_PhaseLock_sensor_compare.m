clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list            = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(sb))] ;
    
    cond_main               = {'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.MinEvoked', ...
        'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse'};
    
    for ncue = 1:2
        
        fname_in                        = ['../data/paper_data/' suj '.' cond_main{ncue} '.PhaseLockingValueAndFreq.mat'];
                
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        clear freq ;
        
        phase_lock                      = h_transform_freq(phase_lock,{1:2,3:6},{'Occipital Cortex','Auditory Cortex'});
        [tmp{1},tmp{2}]                 = h_prepareBaseline(phase_lock,[-0.6 -0.2],[2 20],[-0.2 2],'no');
        
        allsuj_activation{sb,ncue}      = tmp{1};
        allsuj_baselineRep{sb,ncue}     = tmp{2};
        
        
    end
end

clearvars -except allsuj_*;

figure;
i = 0 ;

for ncue = 1:2
    for nchan = 1:2
        
        i = i + 1;
        subplot(2,2,i)
        
        cfg                 = [];
        cfg.channel         = nchan;
        %         cfg.parameter       = 'stat';
        %         cfg.maskparameter   = 'mask';
        %         cfg.maskstyle       = 'outline';
        cfg.zlim            = [0 0.05];
        
        ft_singleplotTFR(cfg,ft_freqgrandaverage([],allsuj_activation{:,ncue}));
    end
end


nsuj                    = size(allsuj_activation,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_activation{1},'virt','t'); clc;

for ncue = 1:size(allsuj_activation,2)
    
    cfg                     = [];
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    
    cfg.correctm            = 'cluster';
    cfg.neighbours          = neighbours;
    
    %     cfg.latency             = [1.2 2];
    %     cfg.frequency           = [60 100];
    %     cfg.avgoverfreq         = 'yes';
    
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    cfg.minnbchan           = 0;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    stat{ncue}              = ft_freqstatistics(cfg, allsuj_activation{:,ncue},allsuj_baselineRep{:,ncue});
    
end

for ncue = 1:2
    [min_p(ncue),p_val{ncue}]      = h_pValSort(stat{ncue});
end

figure;
i = 0;

for ncue = [2 1]
    for nchan = 1:length(stat{ncue}.label)
        
        stat_to_plot       = stat{ncue};
        stat_to_plot.mask  = stat_to_plot.prob < 0.4;
        
        i = i + 1;
        
        subplot(2,2,i)
        
        cfg                 = [];
        cfg.channel         = nchan;
        cfg.parameter       = 'stat';
        cfg.maskparameter   = 'mask';
        cfg.maskstyle       = 'outline';
        cfg.zlim            = [-5 5];
        
        ft_singleplotTFR(cfg,stat_to_plot);
        
        list_ix             = {''};
        
        title(stat_to_plot.label{nchan})
        
        colormap(viridis)
    end
end
