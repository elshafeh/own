clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]                      = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}                            = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                             = suj_list{sb};
        dir_data                        = '../data/dis_rep4rev/';
        fname_in                        = [dir_data suj '.DIS.waveletPOW.40t120Hz.m1000p2000.AvgTrials.MinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in); load(fname_in);
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        allsuj_activation{ngroup}{sb,1}   = freq;
        allsuj_activation{ngroup}{sb,2}   = freq; clear freq ;
        
        fname_in                          = [dir_data suj '.equifDIS.waveletPOW.40t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in); load(fname_in);
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        allsuj_baselineRep{ngroup}{sb,2}  = freq; clear freq ;
        
        fname_in                          = [dir_data suj '.fDIS.waveletPOW.40t120Hz.m1000p2000.AvgTrials.MinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in); load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        allsuj_baselineRep{ngroup}{sb,1}  = freq; clear freq ;
        
    end
end

clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_baselineRep)
    
    nsuj                        = size(allsuj_activation{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'meg','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        
        cfg.frequency           = [50 110];
        cfg.latency             = [0 0.35];
        
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        
        cfg.correctm            = 'cluster';
        
        cfg.neighbours          = neighbours;
        
        cfg.clusteralpha        = 0.05;
        
        cfg.alpha               = 0.025;
        
        cfg.tail                = 1;
        cfg.clustertail         = 1;
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        cfg.minnbchan           = 2;
        
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
        
        
        list_channel                                = {'MLC17', 'MLC25', 'MLF67', 'MLP44', 'MLP45', 'MLP56', ...
            'MLP57', 'MLT14', 'MLT15', 'MRF66', 'MRF67', 'MRT13', 'MRT14', 'MRT24'};
        
        plimit                                      = 0.05;
        stat2plot                                   = h_plotStat(stat{ngroup,ncue},10e-12,plimit);
        
        nrow                                        = 2;
        ncol                                        = 4;
        
        ix = ix +1 ;
        subplot(nrow,ncol,ix)
        
        zlimit                                      = 1;
        
        cfg                                         = [];
        cfg.layout                                  = 'CTF275.lay';
        cfg.comment                                 = 'no';
        cfg.colorbar                                = 'no';
        cfg.zlim                                    = [-zlimit zlimit];
        cfg.highlight                               = 'on';
        cfg.highlightchannel                        = list_channel;
        cfg.highlightsymbol                         = '.';
        cfg.highlightcolor                          = [1 0 0];
        cfg.highlightsize                           = 10;
        cfg.highlightfontsize                       = 8;
        cfg.marker                                  = 'off';
        ft_topoplotER(cfg,stat2plot);
        
        
        ix = ix +1 ;
        subplot(nrow,ncol,ix)
        
        cfg                                         = [];
        cfg.channel                                 = list_channel;
        cfg.comment                                 = 'no';
        cfg.colorbar                                = 'yes';
        cfg.zlim                                    = [-zlimit zlimit];
        ft_singleplotTFR(cfg,stat2plot);
        title('');
        
        cfg                                         = [];
        cfg.channel                                 = list_channel; % 1:275; % list_channel;
        cfg.avgoverchan                             = 'yes';
        nw_data                                     = ft_selectdata(cfg,stat2plot);
        
        ix = ix +1 ;
        subplot(nrow,ncol,ix)
        hold on
        plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)));
        xlim([nw_data.freq(1) nw_data.freq(end)])
        ylim([0 2])
        
        ix = ix +1 ;
        subplot(nrow,ncol,ix)
        hold on
        plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)));
        xlim([nw_data.time(1) nw_data.time(end)])
        ylim([0 2])
        
    end
end