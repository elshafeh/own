clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

% [~,allsuj,~]        = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% 
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);
% 
% for ngroup = 1:length(suj_group)
%     
%     suj_list = suj_group{ngroup};
%     
%     for sb = 1:length(suj_list)
%         
%         list_ix_cue    = {''};
%         
%         for cnd = 1:length(list_ix_cue)
%             
%             ext_file            = 'waveletPOW.40t150Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
%             suj                 = suj_list{sb};
%             dir_data            = '../../data/ageing_data/';
%             
%             fname_in            = [dir_data suj '.' list_ix_cue{cnd} 'DIS.' ext_file];
%             
%             
%             
%             fprintf('Loading %s\n',fname_in);
%             
%             load(fname_in)
%             
%             if isfield(freq,'check_trialinfo')
%                 freq = rmfield(freq,'check_trialinfo');
%             end
%             
%             allsuj_activation{ngroup}{sb,cnd}   = freq; clear freq ;
%             
%             fname_in            = [dir_data suj '.' list_ix_cue{cnd} 'fDIS.' ext_file];
%             
%             fprintf('Loading %s\n',fname_in);
%             
%             load(fname_in)
%             
%             if isfield(freq,'check_trialinfo')
%                 freq = rmfield(freq,'check_trialinfo');
%             end
%             
%             allsuj_baselineRep{ngroup}{sb,cnd}  = freq; clear freq ;
%             
%         end
%     end
% end
% 
% clearvars -except allsuj_*;
% 
% for ngroup = 1:length(allsuj_baselineRep)
%     
%     nsuj                        = size(allsuj_activation{ngroup},1);
%     [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'meg','t'); clc;
%     
%     for ncue = 1:size(allsuj_activation{ngroup},2)
%         
%         cfg                     = [];
%         cfg.clusterstatistic    = 'maxsum';
%         
%         cfg.frequency           = [50 110];
%         cfg.latency             = [0 0.35];
%         
%         cfg.method              = 'montecarlo';
%         cfg.statistic           = 'depsamplesT';
%         cfg.correctm            = 'cluster';
%         cfg.neighbours          = neighbours;
%         
%         cfg.clusteralpha        = 0.05; %  !!!!
%         
%         cfg.alpha               = 0.025;
%         
%         cfg.tail                = 1; %  !!!!!!!!
%         cfg.clustertail         = 1; %  !!!!!!!!
%         
%         cfg.numrandomization    = 1000;
%         cfg.design              = design;
%         cfg.uvar                = 1;
%         cfg.ivar                = 2;
%         
%         cfg.minnbchan           = 2;
%         stat{ngroup,1}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
%         
%         stat{ngroup,1}          = rmfield(stat{ngroup,1},'cfg');
%         
%     end
% end
% 
% save('../../data/stat/ageing_gamma_sensor_sep.mat','stat');

load('../../data/stat/ageing_gamma_sensor_sep.mat');


for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val ;

ix          = 0;
figure;

for ngroup = [2 1]
    
    ncue                                        = 1;
    plimit                                      = 0.05;
    stat2plot                                   = h_plotStat(stat{ngroup,ncue},0.0000000000000000000001,plimit);
    zlimit                                      = 1;
    
    list_channel  = {'MLC17', 'MLF67', 'MLP45', 'MLP55', 'MLP56', 'MLP57', 'MLT14', 'MLT15', 'MLT16', ...
        'MLT24', 'MLT25', 'MLT26', 'MLT35', 'MLT36', 'MLT45', 'MRF67', 'MRP57', 'MRT13', 'MRT14', 'MRT15', 'MRT23', 'MRT24'};
    
    n_row                                       = 2;
    n_col                                       = 5;
    
    ix = ix +1 ;
    subplot(n_row,n_col,ix)
    
    cfg                                         = [];
    cfg.layout                                  = 'CTF275.lay';
    cfg.comment                                 = 'no';
    cfg.colorbar                                = 'yes';
    cfg.zlim                                    = [-zlimit zlimit];
    cfg.marker                                  = 'off';
    cfg.highlight                               = 'off';
    cfg.highlightchannel                        =  list_channel;
    cfg.highlightsymbol                         = '.';
    cfg.highlightcolor                          = [0 0 0];
    cfg.highlightsize                           = 20;
    cfg.highlightfontsize                       = 8;
    ft_topoplotER(cfg,stat2plot);
    
    cfg                                         = [];
    cfg.channel                                 = list_channel;
    cfg.avgoverchan                             = 'yes';
    nw_data                                     = ft_selectdata(cfg,stat2plot);
    
    ix = ix +1 ;
    subplot(n_row,n_col,ix:ix+1)
    
    zlimit                                      = 1.5;
    
    cfg                                         = [];
    cfg.channel                                 = list_channel;
    cfg.parameter                               = 'powspctrm';
    cfg.zlim                                    = [-zlimit zlimit];
    cfg.xlim                                    = [nw_data.time(1) nw_data.time(end)];
    ft_singleplotTFR(cfg,stat2plot); title('')
    
    ix = ix +2 ;
    subplot(n_row,n_col,ix)
    
    hold on
    plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)),'LineWidth',3);
    xlim([nw_data.freq(1) nw_data.freq(end)])
    ylim([0 zlimit])
    
    grid;
    
    ix = ix +1 ;
    subplot(n_row,n_col,ix)
    
    hold on
    plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)),'LineWidth',3);
    xlim([nw_data.time(1) nw_data.time(end)])
    ylim([0 zlimit])
    
    grid;
    
end