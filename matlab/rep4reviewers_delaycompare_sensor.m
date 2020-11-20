clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);
%
% for ngroup = 1:length(suj_group)
%
%     suj_list = suj_group{ngroup};
%
%     for sb = 1:length(suj_list)
%
%         list_ix_cue    = {'','1','2'};
%
%         for ncue = 1:length(list_ix_cue)
%
%             ext_file            = 'waveletPOW.1t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
%             suj                 = suj_list{sb};
%             dir_data            = '../data/dis_rep4rev/';
%             fname_in            = [dir_data suj '.' list_ix_cue{ncue} 'DIS.' ext_file];
%
%             fprintf('Loading %s\n',fname_in);
%
%             load(fname_in)
%
%             if isfield(freq,'check_trialinfo')
%                 freq = rmfield(freq,'check_trialinfo');
%             end
%
%             allsuj_activation{ngroup}{sb,ncue}   = freq; clear freq ;
%
%             fname_in            = [dir_data suj '.' list_ix_cue{ncue} 'fDIS.' ext_file];
%
%             fprintf('Loading %s\n',fname_in);
%
%             load(fname_in)
%
%             if isfield(freq,'check_trialinfo')
%                 freq = rmfield(freq,'check_trialinfo');
%             end
%
%             allsuj_baselineRep{ngroup}{sb,ncue}  = freq; clear freq ;
%
%         end
%     end
% end
%
% clearvars -except allsuj_*;
%
% % load ../data/data_fieldtrip/ageing_dis_fdis_basleine_contrast_grand_average.mat ;
% % load ../data/data_fieldtrip/ageing_dis_fdis_basleine_contrast_stat_3neigh.mat
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
%         %         cfg.avgovertime         = 'yes';
%         %         cfg.avgoverfreq         = 'yes';
%
%         cfg.frequency           = [50 110];
%         cfg.latency             = [0 0.35];
%
%         cfg.method              = 'montecarlo';
%         cfg.statistic           = 'depsamplesT';
%
%         cfg.correctm            = 'cluster';
%
%         cfg.neighbours          = neighbours;
%
%         cfg.clusteralpha        = 0.05; %  !!!!
%
%         cfg.alpha               = 0.025;
%
%         cfg.tail                = 1; %  !!!
%         cfg.clustertail         = 1; %  !!!
%
%         cfg.numrandomization    = 1000;
%         cfg.design              = design;
%         cfg.uvar                = 1;
%         cfg.ivar                = 2;
%
%         cfg.minnbchan           = 2;
%         stat{ngroup,ncue}       = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
%
%     end
% end

load ../data/stat_data/delaycompare_sensor_gamma.mat

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val ;

ix = 0;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        plimit                                      = [0.05 0.08 0.05]; % [0.05 0.2 0.4];
        
        stat2plot                                   = h_plotStat(stat{ngroup,ncue},10e-12,plimit(ncue));
        
        ix = ix +1 ;
        subplot(3,2,ix)
        
        zlimit                                      = 0.5;
        
        cfg                                         = [];
        cfg.layout                                  = 'CTF275.lay';
        cfg.comment                                 = 'no';
        cfg.colorbar                                = 'no';
        cfg.zlim                                    = [-zlimit zlimit];
        cfg.marker                                  = 'off';
        ft_topoplotER(cfg,stat2plot);
        
        
        ix = ix +1 ;
        subplot(3,2,ix)
        
        zlimit                                      = 1;
        
        cfg                                         = [];
        cfg.channel                                 = {'MLC17', 'MLC25', 'MLF67', 'MLP44', 'MLP45', 'MLP56', ...
            'MLP57', 'MLT14', 'MLT15', 'MRF66', 'MRF67', 'MRT13', 'MRT14', 'MRT24'};
        cfg.comment                                 = 'no';
        cfg.colorbar                                = 'yes';
        cfg.zlim                                    = [-zlimit zlimit];
        ft_singleplotTFR(cfg,stat2plot);            
        title('');
        
    end
end