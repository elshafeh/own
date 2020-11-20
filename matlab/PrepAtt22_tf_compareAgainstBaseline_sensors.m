
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}    = suj_list(2:22);

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);
suj_group{1}        = [allsuj(2:15,1);allsuj(2:15,2)];


for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for cnd = 1:length(list_ix_cue)
            
            suj                 = suj_list{sb};
            
            %             fname_in            = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' list_ix_cue{cnd} 'CnD.waveletPOW.40t150Hz.m1000p2000.10Mstep.AvgTrials.MinEvoked.mat'];
            fname_in            = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.' list_ix_cue{cnd} 'CnD.all.wav.40t150Hz.m2000p2000.MinusEvoked.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            freq                                = ft_freqdescriptives([],freq);
            freq                                = rmfield(freq,'cfg');
            
            [tmp{1},tmp{2}]                     = h_prepareBaseline(freq,[-0.4 -0.2],[50 110],[0 2],'no');
            
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
        
        cfg.latency             = [1 2];
        
        %         cfg.frequency           = [60 100];
        
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
        
        cfg.minnbchan           = 2; % !!
        stat{ngroup,1}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
        cfg.minnbchan           = 3; % !!
        stat{ngroup,2}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
        %         stat{ngroup,ncue}       = rmfield(stat{ngroup,ncue},'cfg');
        
    end
end

% load ../data/data_fieldtrip/post_target_gamma_1_allyoung_2_youngold.mat

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        figure;
        
        %         i                       = 0 ;
        %         i                       = i + 1;
        
        plimit                  = 0.05;
        
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        
        subplot(2,2,1)
        
        av_lim                  = 0.1;
        
        cfg                     = [];
        cfg.layout              = 'CTF275.lay';
        %         cfg.xlim                = -0.2:0.2:1.2;
        cfg.comment             = 'no';
        cfg.zlim                = [-av_lim av_lim];
        cfg.marker              = 'off';
        ft_topoplotER(cfg,stat2plot);
        
        list_channel            = 1:275;
        
        cfg                     = [];
        cfg.channel             = list_channel; %1:275; %  list_channel;
        cfg.avgoverchan         = 'yes';
        nw_data                 = ft_selectdata(cfg,stat2plot);
        
        subplot(2,2,2)
        cfg                     = [];
        cfg.channel             = list_channel; %1:275; %list_channel;
        cfg.parameter           = 'powspctrm';
        cfg.zlim                = [-av_lim av_lim];
        cfg.xlim                = [nw_data.time(1) nw_data.time(end)];
        ft_singleplotTFR(cfg,stat2plot); title('')
        
        
        subplot(2,2,3)
        hold on
        plot(nw_data.freq,squeeze(nanmean(nw_data.powspctrm,3)));
        xlim([nw_data.freq(1) nw_data.freq(end)])
        ylim([0 av_lim])
        
        subplot(2,2,4)
        hold on
        plot(nw_data.time,squeeze(nanmean(nw_data.powspctrm,2)));
        xlim([nw_data.time(1) nw_data.time(end)])
        ylim([0 av_lim])
        
    end
end


