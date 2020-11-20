
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}    = suj_list(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for cnd = 1:length(list_ix_cue)
            
            suj                 = suj_list{sb};
            
            fname_in            = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' list_ix_cue{cnd} 'nDT.waveletPOW.40t150Hz.m2000p1000.10Mstep.AvgTrials.MinEvoked.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq                                = ft_freqdescriptives([],freq);
            freq                                = rmfield(freq,'cfg');
            
            [tmp{1},tmp{2}]                     = h_prepareBaseline(freq,[-0.4 -0.2],[40 110],[-0.1 0.5],'no');
            
            allsuj_activation{ngroup}{sb,cnd}   = tmp{1};
            allsuj_baselineRep{ngroup}{sb,cnd}  = tmp{2};
            
            clear tmp freq
            
        end
        
        clear big_freq
        
    end
end

clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                        = size(allsuj_activation{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'meg','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        
        cfg.frequency           = [40 110];
        
        %         cfg.avgoverfreq         = 'yes';
        %         cfg.avgovertime         = 'yes';
        
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        
        cfg.neighbours          = neighbours;
        
        cfg.clusteralpha        = 0.05; % !!
        
        cfg.alpha               = 0.025;
        
        
        cfg.tail                = 1; % !!
        cfg.clustertail         = 1; % !!
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        cfg.minnbchan           = 3; % !!!
        stat{ngroup,1}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
        cfg.minnbchan           = 4; % !!!
        stat{ngroup,2}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
    end
end


for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val;

ix = 0 ;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        ix = ix + 1;
        
        plimit                  = 0.05;
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        
        subplot(2,1,ix)
        cfg                     = [];
        cfg.layout              = 'CTF275.lay';
        cfg.comment             = 'no';
        cfg.marker              = 'off';
        cfg.zlim                = [-1 1];
        ft_topoplotER(cfg,stat2plot);
        
    end
end