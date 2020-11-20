clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}                    = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for ncue = 1:length(list_ix_cue)
            
            ext_file            = 'eeg.nonfilt.waveletPOW.10t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
            suj                 = suj_list{sb};
            dir_data            = '../data/dis_rep4rev/';
            fname_in            = [dir_data suj '.' list_ix_cue{ncue} 'DIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            allsuj_activation{ngroup}{sb,ncue}   = freq; clear freq ;
            
            fname_in            = [dir_data suj '.' list_ix_cue{ncue} 'fDIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            allsuj_baselineRep{ngroup}{sb,ncue}  = freq; clear freq ;
            
        end
    end
end

clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_baselineRep)
    
    nsuj                        = size(allsuj_activation{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'none','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        
        cfg.frequency           = [20 110];
        cfg.latency             = [-0.1 0.3];
        
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        
        cfg.correctm            = 'bonferroni';
        
        cfg.neighbours          = neighbours;
        
        cfg.clusteralpha        = 0.05;
        
        cfg.alpha               = 0.025;
        
        cfg.tail                = 1; 
        cfg.clustertail         = 1; 
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        cfg.minnbchan           = 0;
        
        stat{ngroup,ncue}       = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
    end
end


for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val ;

ix = 0;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        stat2plot                                       = h_plotStat(stat{ngroup,ncue},10e-12,0.05);
        
        for nchan = 1:length(stat2plot.label)
            
            ix = ix +1 ;
            subplot(4,2,ix)
            
            zlimit                                      = 2;
            
            cfg                                         = [];
            cfg.layout                                  = 'elan_lay.mat';
            cfg.channel                                 = nchan;
            cfg.comment                                 = 'no';
            cfg.colorbar                                = 'yes';
            cfg.zlim                                    = [-zlimit zlimit];
            
            ft_singleplotTFR(cfg,stat2plot);
            
        end
    end
end