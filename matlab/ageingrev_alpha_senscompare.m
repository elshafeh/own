clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]                                = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}                                = allsuj(2:15,1);
suj_group{2}                                = allsuj(2:15,2);

for ngrp = 1:length(suj_group)

    suj_list = suj_group{ngrp};

    for sb = 1:length(suj_list)

        suj                                 = suj_list{sb};
        cond_main                           = 'CnD';

        list_cue                            = {''};

        for ncue = 1:length(list_cue)

            ext_name                        = 'waveletPOW.1t50Hz.m3000p3000.50Mstep.AvgTrials.MinEvoked.mat';
            dir_data                        = '../../data/alpha_emergence/';
            fname_in                        = [dir_data suj '.' list_cue{ncue} cond_main '.' ext_name];

            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)

            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end

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

[~,neighbours]                      = h_create_design_neighbours(length(allsuj_data{1}),allsuj_data{1}{1},'meg','t'); clc;
nsubj                               = 14;

cfg                                 = [];

cfg.latency                         = [0 1.2];
cfg.frequency                       = [5 45];

cfg.statistic                       = 'indepsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'cluster';

cfg.clusteralpha                    = 0.01; % !!

cfg.clusterstatistic                = 'maxsum';
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.neighbours                      = neighbours;
cfg.design                          = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.ivar                            = 1;
cfg.minnbchan                       = 4; % !!


for ncue = 1:size(allsuj_data{1},2)
    stat{ncue}                      = ft_freqstatistics(cfg, allsuj_data{2}{:,ncue}, allsuj_data{1}{:,ncue}); % young minus control
    stat{ncue}                      = rmfield(stat{ncue},'cfg');
    [min_p(ncue), p_val{ncue}]      = h_pValSort(stat{ncue}) ;
end

save('../../data/stat/alpha_emergence_0p01_stat.mat','stat','-v7.3');

% for ncue = 1:length(stat)
%     [min_p(ncue), p_val{ncue}]                      = h_pValSort(stat{ncue}) ;
% end
%
% figure;
%
% plimit                                              = 0.05;
% stat2plot                                           = h_plotStat(stat{ncue},1e-25,plimit);
%
% for ncue = 1:length(stat)
%
%     zlimit                                          = 1;
%
%     subplot(3,4,1:4)
%     set(gca,'FontSize',16)
%
%     cfg                                             = [];
%     cfg.layout                                      = 'CTF275.lay';
%     cfg.zlim                                        = [-zlimit zlimit];
%     cfg.marker                                      = 'off';
%     cfg.comment                                     = 'no';
%     ft_topoplotER(cfg,stat2plot);
%     title(upper('stat avg over 0-1200ms 5-50Hz'));
%
% end
%
% ix                                                  = 4;
%
% list_chan                                           = {'M*O*','M*T*','M*P*','M*F*'};
% zlimit                                              = 3;
%
% for nchan = 1:length(list_chan)
%     cfg                                             = [];
%     cfg.channel                                     = list_chan{nchan};
%     cfg.avgoverchan                                 = 'yes';
%     nw_data{nchan}                                  = ft_selectdata(cfg,stat2plot);
% end
%
% for ncue = 1:length(stat)
%     for nchan = 1:length(list_chan)
%
%         subplot(3,4,ix+nchan)
%         set(gca,'FontSize',16)
%
%         cfg                                         = [];
%         cfg.comment                                 = 'no';
%         cfg.colorbar                                = 'yes';
%         cfg.zlim                                    = [-1 1];
%         ft_singleplotTFR(cfg,nw_data{nchan});
%         title([list_chan{nchan} ' TF']);
%         set(gca,'FontSize',16)
%
%     end
% end
%
% zlimit                                              = 1.5;
%
% subplot(3,4,9:10)
% set(gca,'FontSize',16)
% hold on
%
% for nchan = 1:length(list_chan)
%     plot(nw_data{nchan}.freq,squeeze(nanmean(nw_data{nchan}.powspctrm,3)),'LineWidth',2.5);
%     xlim([nw_data{nchan}.freq(1) nw_data{nchan}.freq(end)])
%     ylim([0 zlimit])
%     grid;
%     title('avg over time');
% end
%
% grid;
% legend(list_chan);
%
% subplot(3,4,11:12)
% set(gca,'FontSize',16)
% hold on
%
% for nchan = 1:length(list_chan)
%     plot(nw_data{nchan}.time,squeeze(nanmean(nw_data{nchan}.powspctrm,2)),'LineWidth',2.5);
%     xlim([nw_data{nchan}.time(1) nw_data{nchan}.time(end)])
%     ylim([0 zlimit]);
%     title('avg over freq');
% end
%
% grid;
% legend(list_chan,'Location','NorthWest');