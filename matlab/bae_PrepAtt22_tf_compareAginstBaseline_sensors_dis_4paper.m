clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% suj_group{1}        = [allsuj(2:15,1);allsuj(2:15,2)];

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for cnd = 1:length(list_ix_cue)
            
            ext_file            = 'waveletPOW.40t150Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
            
            suj                 = suj_list{sb};
            fname_in            = ['../data/' suj '/field/' suj '.' list_ix_cue{cnd} 'DIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            allsuj_activation{ngroup}{sb,cnd}   = freq; clear freq ;
            
            fname_in            = ['../data/' suj '/field/' suj '.' list_ix_cue{cnd} 'fDIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            allsuj_baselineRep{ngroup}{sb,cnd}  = freq; clear freq ;
            
        end
    end
end

clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_baselineRep)
    
    nsuj                        = size(allsuj_activation{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'meg','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        
        %         cfg.avgovertime         = 'yes';
        %         cfg.avgoverfreq         = 'yes';
        
        cfg.frequency           = [50 110];
        cfg.latency             = [0 0.35];
        
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        cfg.clusteralpha        = 0.05;
        cfg.alpha               = 0.025;
        
        cfg.minnbchan           = 2;
        
        cfg.tail                = 1; %  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        cfg.clustertail         = 1; %  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{1,ncue}            = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
        cfg.minnbchan           = 3;
        
        stat{2,ncue}            = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
    end
end

clearvars -except allsuj_* stat min_p p_val ;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        subplot(1,size(stat,1),ngroup)
        
        plimit                  = 0.05;
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        zlimit                  = 1;
        
        cfg                     = [];
        cfg.layout              = 'CTF275.lay';
        cfg.comment             = 'no';
        cfg.colorbar            = 'yes';
        cfg.zlim                = [-zlimit zlimit];
        cfg.marker              = 'off';
        %         cfg.colormap            = redblue;
        ft_topoplotER(cfg,stat2plot);
        
    end
end