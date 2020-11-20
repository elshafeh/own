clear ; clc ;

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        list_cue                 = {''};
        
        for ncue = 1:length(list_cue)
            
            ext_name                = 'waveletPOW.1t20Hz.m3000p3000.AvgTrials.80Slct.mat';
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_cue{ncue} cond_main '.' ext_name];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            %             load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
            
            %             cfg                             = [];
            %             cfg.trials                      = [trial_array{:}];
            
            freq                            = ft_freqdescriptives([],freq);
            
            cfg                             = [];
            cfg.baseline                    = [-0.6 -0.2];
            cfg.baselinetype                = 'relchange';
            freq                            = ft_freqbaseline(cfg,freq);
            
            allsuj_data{ngrp}{sb,ncue}      = freq; clear tmp ;
        end
        
        clear freq
        
    end
end

clearvars -except allsuj_data ; clc ;

[~,neighbours]          = h_create_design_neighbours(length(allsuj_data{1}),allsuj_data{1}{1},'meg','t'); clc;
nsubj                   = 14;

cfg                     = [];

cfg.latency             = [-0.2 1.2];
cfg.frequency           = [7 15];

cfg.statistic           = 'indepsamplesT';
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05; % !!
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.ivar                = 1;
cfg.minnbchan           = 4; % !!

for ncue = 1:size(allsuj_data{1},2)
    stat{ncue}                    = ft_freqstatistics(cfg, allsuj_data{2}{:,ncue}, allsuj_data{1}{:,ncue}); % young minus control
    [min_p(ncue), p_val{ncue}]    = h_pValSort(stat{ncue}) ;
end

% for ncue = 1:length(stat)
%
%     zlimit                  = 0.5;
%
%     plimit                  = 0.05;
%
%     stat2plot               = h_plotStat(stat{ncue},0.00001,plimit);
%
%     cfg         = [];
%     cfg.layout  = 'CTF275.lay';
%     %     cfg.xlim    = -0.2:0.1:1.2;
%     cfg.zlim    = [-zlimit zlimit];
%     cfg.marker  = 'off';
%     %     cfg.comment = 'no';
%     ft_topoplotER(cfg,stat2plot);
%
%     %     figure;
%     %
%     %     cfg.xlim    = [0.5 0.7];
%     %     ft_topoplotER(cfg,stat2plot);
%     %
%     %     figure;
%     %     cfg.xlim    = [0.8 1.2];
%     %     ft_topoplotER(cfg,stat2plot);
%
%
% end


zlimit                  = 2;
plimit                  = 0.05;

stat2plot               = h_plotStat(stat{ncue},0.00001,plimit);

cfg         = [];
cfg.ylim    = [11 15];
cfg.xlim    = [0.6 1];
cfg.layout  = 'CTF275.lay';
cfg.zlim    = [-zlimit zlimit];
cfg.marker  = 'off';
cfg.comment = 'no';
cfg.colorbar  = 'yes';
subplot(1,3,1)
ft_topoplotER(cfg,stat2plot); title('Stat Young v Old');
zlimit       = 0.2;
cfg.zlim    = [-zlimit zlimit];
subplot(1,3,2)
ft_topoplotER(cfg,ft_freqgrandaverage([],allsuj_data{2}{:,1})); title('Young');
subplot(1,3,3)
ft_topoplotER(cfg,ft_freqgrandaverage([],allsuj_data{1}{:,1})); title('Old');



cfg             = [];
cfg.channel     = {'MLC13', 'MLC21', 'MLC22', 'MLC31', 'MLC41', 'MLC51', 'MLC52', 'MLC53', 'MLC61', 'MRC51', 'MRC61', 'MZC02'};
cfg.zlim        = [-zlimit zlimit];
subplot(2,2,2)
ft_singleplotTFR(cfg,stat2plot) ; title('');

cfg             = [];
cfg.channel     = {'MLC13', 'MLC21', 'MLC22', 'MLC31', 'MLC41', 'MLC51', 'MLC52', 'MLC53', 'MLC61', 'MRC51', 'MRC61', 'MZC02'};
cfg.avgoverchan = 'yes';
nw_data         = ft_selectdata(cfg,stat2plot);

subplot(2,2,3)
plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)));
xlim([nw_data.freq(1) nw_data.freq(end)])
ylim([0 0.7])
vline(70,'--k');
vline(90,'--k');

cfg             = [];
cfg.frequency   = [70 90];
cfg.avgoverfreq = 'yes';
nw_data         = ft_selectdata(cfg,nw_data);

subplot(2,2,4)
plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)));
xlim([nw_data.time(1) nw_data.time(end)])
vline(0.35,'--k');
vline(0.65,'--k');