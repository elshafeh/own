clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_group{1} = {''};

for ngroup = 1:length(suj_group)    
    
    suj_list           = [1:4 8:17];
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for cnd = 1:length(list_ix_cue)
            
            suj                 = ['yc' num2str(suj_list(sb))] ;
            
            fname_in            = ['../../PAT_MEG21/pat.field/data/' suj '.' list_ix_cue{cnd} 'CnD.all.wav.1t30Hz.m3000p3000.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            [tmp{1},tmp{2}]                     = h_prepareBaseline(freq,[-0.6 -0.2],[5 25],[-0.2 2],'no');
            
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
        
        %         cfg.latency             = [-0.2 1.2];
        
        cfg.frequency           = [7 20];
        
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        
        cfg.clusteralpha        = 0.05; % !!
        
        cfg.alpha               = 0.025;
        
        cfg.minnbchan           = 4; % !!
        
        cfg.tail                = 0; % !!
        cfg.clustertail         = 0; % !!
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ncue}       = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        stat{ngroup,ncue}       = rmfield(stat{ngroup,ncue},'cfg');
        
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val;

for ngroup = 1:size(stat,1)
    
    for ncue = 1:size(stat,2)
        
        plimit                  = 0.05;
        
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        
        subplot(1,1,ngroup)
        
        cfg         = [];
        cfg.layout  = 'CTF275.lay';
        cfg.zlim    = [-3 3];
        cfg.marker  = 'off';
        ft_topoplotTFR(cfg,stat2plot);
                
    end
end

stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);

cfg         = [];
cfg.channel = {'MLO11', 'MLO12', 'MLO21', 'MLO22', 'MLO31', 'MLO41', 'MLO42', 'MRO11', ...
    'MRO12', 'MRO21', 'MRO22', 'MRO31', 'MRO32', 'MRO41', 'MRO42'};
cfg.avgoverchan = 'yes';
stat2plot   = ft_selectdata(cfg,stat2plot);

subplot(1,3,1)
cfg         = [];
cfg.zlim    = [-3 3];
cfg.marker  = 'off';
ft_singleplotTFR(cfg,stat2plot);
title('');

subplot(1,3,2)
cfg = [];
cfg.latency  = [0.6 1];
cfg.avgovertime = 'yes';
nw_stat2plot   = ft_selectdata(cfg,stat2plot);

nw_stat2plot.powspctrm(nw_stat2plot.powspctrm<0) = 0 ;

plot(nw_stat2plot.freq,squeeze(nw_stat2plot.powspctrm));
ylim([-2 2]);
xlim([nw_stat2plot.freq(1) nw_stat2plot.freq(end)])

subplot(1,3,3)
cfg = [];
cfg.latency  = [0.2 0.6];
cfg.avgovertime = 'yes';
nw_stat2plot   = ft_selectdata(cfg,stat2plot);

nw_stat2plot.powspctrm(nw_stat2plot.powspctrm>0) = 0 ;

plot(nw_stat2plot.freq,squeeze(nw_stat2plot.powspctrm));
ylim([-5 5]);
xlim([nw_stat2plot.freq(1) nw_stat2plot.freq(end)])