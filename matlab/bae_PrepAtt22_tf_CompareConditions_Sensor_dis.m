clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% 
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {'V1','L1','R1','N1'};
        
        for cnd = 1:length(list_ix_cue)
            
            suj                 = suj_list{sb};
            fname_in            = ['../data/' suj '/field/' suj '.' list_ix_cue{cnd} 'DIS.waveletPOW.1t20Hz.m1000p1000.50Mstep.AvgTrials.MinEvoked.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            dis_data            = freq; clear freq ;
            
            fname_in            = ['../data/' suj '/field/' suj '.' list_ix_cue{cnd} 'fDIS.waveletPOW.1t20Hz.m1000p1000.50Mstep.AvgTrials.MinEvoked.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            fdis_data                   = freq; clear freq ;
           
            cfg                         = [];
            cfg.parameter               = 'powspctrm';
            cfg.operation               = 'x1-x2';
            allsuj_data{ngroup}{sb,cnd} = ft_math(cfg,dis_data,fdis_data);
            
            clear dis_data fdis_data
            
        end
    end
end
            
clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_data)
    
    ix_test                     = [1 4; 2 4; 3 4; 2 3];
   
    nsuj                        = size(allsuj_data{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'meg','t'); clc;
    
    for ntest = 1:size(ix_test,1)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        cfg.latency             = [0.2 0.65];
        cfg.frequency           = [7 15];
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        cfg.clusteralpha        = 0.05;
        cfg.alpha               = 0.025;
        cfg.minnbchan           = 3;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ntest}      = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)},allsuj_data{ngroup}{:,ix_test(ntest,2)});
        stat{ngroup,ntest}      = rmfield(stat{ngroup,ntest},'cfg');
        
    end
end

clearvars -except allsuj_* stat;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest), p_val{ngroup,ntest}]  = h_pValSort(stat{ngroup,ntest}) ;
    end
end

clearvars -except allsuj_data list_ix_cue stat min_p p_val

list_test   = {'V versus N','L versus N','R versus N','L versus R'};

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        plimit                  = 0.05;
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        zlimit                  = 0.5;
        
        subplot(2,2,ncue)
        
        cfg                     = [];
        cfg.layout              = 'CTF275.lay';
        cfg.comment             = 'no';
        cfg.colorbar            = 'yes';
        cfg.zlim                = [-zlimit zlimit];
        cfg.marker              = 'off';
        ft_topoplotER(cfg,stat2plot);
       
        colormap(redblue)
        
        title(list_test{ncue},'FontSize',16);
        
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        zlimit                  = 0.5;
        
        cfg                     = [];
        cfg.channel             = 'all';
        cfg.avgoverchan         = 'yes';
        nw_data                 = ft_selectdata(cfg,stat2plot);
        
        subplot(1,2,1)
        hold on
        plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)),'LineWidth',2);
        xlim([nw_data.freq(1) nw_data.freq(end)])
        ylim([-0.4 0])
        
        subplot(1,2,2)
        hold on
        plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)),'LineWidth',2);
        xlim([nw_data.time(1) nw_data.time(end)])
        ylim([-0.4 0])
        
    end
    
    legend(list_test,'Location','SouthEast')
    
end