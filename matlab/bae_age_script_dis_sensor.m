clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

suj_group{1}    = [allsuj(2:15,1);allsuj(2:15,2)];

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
%         cfg.frequency           = [40 120];
%         cfg.latency             = [0 0.35];
%
%         cfg.method              = 'montecarlo';
%         cfg.statistic           = 'depsamplesT';
%         cfg.correctm            = 'cluster';
%         cfg.neighbours          = neighbours;
%         cfg.clusteralpha        = 0.05;
%         cfg.alpha               = 0.025;
%
%         cfg.minnbchan           = 2;
%
%         cfg.tail                = 1; %  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%         cfg.clustertail         = 1; %  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
%         cfg.numrandomization    = 1000;
%         cfg.design              = design;
%         cfg.uvar                = 1;
%         cfg.ivar                = 2;
%
%         stat{ngroup,ncue}       = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
%         stat{ngroup,ncue}       = rmfield(stat{ngroup,ncue},'cfg');
%
%         [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
%
%     end
% end
%
% clearvars -except allsuj_* stat min_p p_val ;

load('../data_fieldtrip/age_paper_data/dis_sensor_common_gamma_emergence.mat');

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        chan_list               = {'MLT14', 'MLT24', 'MLT34', 'MRF67', 'MRT14', 'MRT24'}; % {'MLP56', 'MLP57', 'MLT14', 'MLT15', 'MLT25', 'MRC17', 'MRF67', 'MRP57', 'MRT13', 'MRT14', 'MRT15', 'MRT23', 'MRT24'};
        
        plimit                  = 0.05;
        stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        
        avg_dis                 = ft_freqgrandaverage([],allsuj_activation{ngroup}{:,ncue});
        avg_fdis                = ft_freqgrandaverage([],allsuj_baselineRep{ngroup}{:,ncue});
        
        avg_dis.powspctrm       = avg_dis.powspctrm - avg_fdis.powspctrm;
        
        cfg                     = [];
        cfg.latency             = [0 0.35];
        cfg.frequency           = [40 120];
        avg_dis                 = ft_selectdata(cfg,avg_dis);
        stat2plot               = ft_selectdata(cfg,stat2plot);
        
        avg_dis.mask            = (stat2plot.powspctrm ~= 0);
        avg_dis.powspctrm       = avg_dis.powspctrm .* avg_dis.mask ;
        
        cfg                     = [];
        cfg.xlim                = [0.1 0.3];
        cfg.ylim                = [60 100];
        cfg.marker              = 'off';
        cfg.layout              = 'CTF275.lay';
        cfg.comment             = 'no';
        cfg.colorbar            = 'yes';
        cfg.marker              = 'off';
        cfg.highlight           = 'on';
        cfg.highlightchannel    =  chan_list;
        cfg.highlightsymbol     = '.';
        cfg.highlightsize       = 10;
        
        zlimit                  = 0.1e+04;
        
        subplot(2,2,1)
        cfg.zlim                = [-zlimit zlimit];
        ft_topoplotER(cfg,avg_dis);
        
        subplot(2,2,2)
        
        cfg                     = [];
        cfg.channel             = chan_list;
        cfg.comment             = 'no';
        cfg.colorbar            = 'yes';
        cfg.zlim                = [-zlimit zlimit];
        cfg.marker              = 'off';
        ft_singleplotTFR(cfg,avg_dis);
        
        cfg                     = [];
        cfg.channel             = chan_list;
        cfg.avgoverchan         = 'yes';
        nw_data_avg             = ft_selectdata(cfg,stat2plot);
        
        subplot(2,2,3)
        hold on
        plot(nw_data_avg.freq,squeeze(mean(nw_data_avg.powspctrm,3)),'LineWidth',2);
        xlim([nw_data_avg.freq(1) nw_data_avg.freq(end)])
        ylim([0 2])
        
        subplot(2,2,4)
        hold on
        plot(nw_data_avg.time,squeeze(mean(nw_data_avg.powspctrm,2)),'LineWidth',2);
        xlim([nw_data_avg.time(1) nw_data_avg.time(end)])
        ylim([0 2])
        
    end
end


        
%         cfg                     = [];
%         cfg.channel             = chan_list;
%         nw_data_all             = ft_selectdata(cfg,stat{ngroup,ncue});
%         cfg.avgoverchan         = 'yes';
%         nw_data_avg             = ft_selectdata(cfg,stat2plot);
%         chan_to_plot            = [];
%         chan_to_plot.label      = {'avg'};
%         chan_to_plot.dimord     = 'chan_freq_time';
%         chan_to_plot.time       = nw_data_avg.time;
%         chan_to_plot.freq       = nw_data_avg.freq;
%         chan_to_plot.stat       = mean(nw_data_all.stat,1);
%
%         chan_to_plot.mask       = (nw_data_avg.powspctrm == 0);
%         zlimit                  = 1;
%         subplot(2,2,1)
% %         cfg.zlim                = [-zlimit zlimit];
% %         ft_topoplotER(cfg,stat2plot);
%
%         cfg.maskparameter       = 'mask';
%         cfg.maskstyle           =  'opacity'; %, 'saturation' or 'outline'
%         cfg.maskalpha           = 0.6 ; % 0 (transparant) and 1 (opaque)