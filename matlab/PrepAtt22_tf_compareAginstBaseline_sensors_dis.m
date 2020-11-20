clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
t_suj_group{1}      = allsuj(2:15,1);
t_suj_group{2}      = allsuj(2:15,2);
suj_group{1}        = [t_suj_group{1};t_suj_group{2}];

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);
%
% % suj_group{1}    ={'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};


for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {'1'};
        
        for cnd = 1:length(list_ix_cue)
            
            ext_file            = 'waveletPOW.1t20Hz.m1000p1000.50Mstep.AvgTrials.MinEvoked.mat';
            suj                 = suj_list{sb};
            dir_data            = '/Volumes/SHORT_LOUIE/dis1_sens_data/';
            fname_in            = [dir_data suj '.' list_ix_cue{cnd} 'DIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            allsuj_activation{ngroup}{sb,cnd}   = freq; clear freq ;
            
            fname_in            = [dir_data suj '.' list_ix_cue{cnd} 'fDIS.' ext_file];
            
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
        
        cfg.frequency           = [5 15];
        cfg.latency             = [-0.1 0.65];
        
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        
        cfg.clusteralpha        = 0.05; %  !!!!
        
        cfg.alpha               = 0.025;
        
        cfg.tail                = 0; %  !!!!!!!!
        cfg.clustertail         = 0; %  !!!!!!!!
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        cfg.minnbchan           = 4;
        stat{ngroup,1}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
        %         cfg.minnbchan           = 3;
        %         stat{ngroup,2}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        %
        %         cfg.minnbchan           = 4;
        %         stat{ngroup,3}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
        %         stat{ngroup,ncue}       = rmfield(stat{ngroup,ncue},'cfg');
        %         [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
        
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
        
        ix = ix +1 ;
        subplot(2,2,ix)
        
        plimit                                      = 0.05;
        stat2plot                                   = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
        zlimit                                      = 2;
        
        stat2plot.powspctrm(stat2plot.powspctrm>0)  = 0;
        
        
        list_channel  = {'MLO11', 'MLO12', 'MLO13', 'MLO14', 'MLO24', 'MLP11', 'MLP21', 'MLP22', 'MLP31', ...
            'MLP32', 'MLP33', 'MLP34', 'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP51', 'MLP52', 'MLP53', ...
            'MLP54', 'MLP55', 'MLP56', 'MLT16', 'MLT27', 'MRO13', 'MRO14', 'MRP33', 'MRP34', 'MRP42', ...
            'MRP43', 'MRP44', 'MRP53', 'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT15', 'MRT16', 'MRT27'};
        
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
        
        
        cfg                     = [];
        cfg.channel             = list_channel; % 1:275; % list_channel;
        cfg.avgoverchan         = 'yes';
        nw_data                 = ft_selectdata(cfg,stat2plot);
        
        ix = ix +1 ;
        subplot(2,2,ix)
        cfg                     = [];
        cfg.channel             = list_channel; %1:275; %list_channel;
        cfg.parameter           = 'powspctrm';
        cfg.zlim                = [-4 4];
        cfg.xlim                = [nw_data.time(1) nw_data.time(end)];
        ft_singleplotTFR(cfg,stat2plot); title('')
        vline(0,'--b')
        
        ix = ix +1 ;
        subplot(2,2,ix)
        hold on
        plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)));
        xlim([nw_data.freq(1) nw_data.freq(end)])
        ylim([-4 0])
        
        ix = ix +1 ;
        subplot(2,2,ix)
        hold on
        plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)));
        xlim([nw_data.time(1) nw_data.time(end)])
        ylim([-4 0])
        
    end
end

% theta
% list_channel = {'MLC13', 'MLF33', 'MLF34', 'MLF43', 'MLF44', 'MLF45', 'MLF52', 'MLF53', ...
%     'MLF54', 'MLF62', 'MLF63', 'MRT22', 'MRT32', 'MRT33', 'MRT41', 'MRT42'};
%
% list_channel ={'MLC17', 'MLF67', 'MLP57', 'MLT13', 'MLT14', 'MLT15', 'MLT16', 'MLT23', 'MLT24', ...
%     'MLT25', 'MLT26', 'MLT33', 'MLT34', 'MLT35', 'MLT44', 'MRC16', 'MRC17', 'MRC24', ...
%     'MRC25', 'MRC32', 'MRF66', 'MRF67', 'MRP35', 'MRP44', 'MRP45', 'MRP57', 'MRT13', ...
%     'MRT14', 'MRT23', 'MRT24'};
%
% beta
% list_channel            = {'MLC13', 'MLC14', 'MLC15', 'MLC22', 'MLC23', 'MLC41', 'MLF35', 'MLF44', 'MLF45', ...
%     'MLF46', 'MLF53', 'MLF54', 'MLF55', 'MLF56', 'MLF62', 'MLF63', 'MLF64', 'MLF65', 'MLO11', ...
%     'MLO12', 'MLO13', 'MLO14', 'MLO23', 'MLO24', 'MLO34', 'MLP22', 'MLP32', 'MLP33', 'MLP34', ...
%     'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP52', 'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT11', 'MLT12', 'MLT16', 'MLT27'};



%     for ngroup = 1:size(stat,1)
%         plimit                  = 0.11;
%         stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
%         cfg                     = [];
%         cfg.channel             = list_chan{nchan};
%         cfg.avgoverchan         = 'yes';
%         nw_data                 = ft_selectdata(cfg,stat2plot);
%     end
%
%
% figure;
%
% i = 0 ;
%
% grand_average_act = ft_freqgrandaverage([],allsuj_activation{1}{:,1});
% grand_average_bsl = ft_freqgrandaverage([],allsuj_baselineRep{1}{:,1});
%
% cfg                 = [];
% cfg.operation       = 'x1-x2';
% cfg.parameter       = 'powspctrm';
% grand_average_bsl   = ft_math(cfg,grand_average_act,grand_average_bsl);
%
% cfg                                 = [];
% cfg.latency                         = [stat{1}.time(1) stat{1}.time(end)];
% cfg.frequency                       = [stat{1}.freq(1) stat{1}.freq(end)];
% grand_average_bsl_slct              = ft_selectdata(cfg,grand_average_bsl);
%
% grand_topo              = grand_average_bsl_slct;
% grand_topo.powspctrm    = grand_topo.powspctrm .* stat{1}.mask;
%
% cfg         = [];
% cfg.layout  = 'CTF275.lay';
% cfg.comment = 'no';
% cfg.colorbar = 'yes';
% cfg.zlim    = [-75 75];
% cfg.marker  = 'off';
% subplot(2,1,1)
% ft_topoplotER(cfg,grand_topo);
%
% grand_topo.powspctrm = grand_topo.powspctrm/10;
%
% cfg                 = [];
% cfg.channel         = {'MLC17', 'MLF67', 'MLP45', 'MLP56', 'MLP57', 'MLT14', 'MLT15', 'MLT24', 'MLT25', 'MRF67', 'MRT13', 'MRT14', 'MRT23', 'MRT24'};;
% cfg.parameter       = 'powspctrm';
% cfg.zlim            = [-75 75];
% subplot(2,1,2)
% ft_singleplotTFR(cfg,grand_topo);
% title('');
%
%
% grand_average_bsl_slct.mask = stat{1}.mask;
% cfg                 = [];
% cfg.channel         = {'MLC17', 'MLF67', 'MLP45', 'MLP56', 'MLP57', 'MLT14', 'MLT15', 'MLT24', 'MLT25', 'MRF67', 'MRT13', 'MRT14', 'MRT23', 'MRT24'};
% cfg.avgoverchan     = 'yes';
% slct_stat           = ft_selectdata(cfg,stat{1});
% slct_avg            = ft_selectdata(cfg,grand_average_bsl_slct);
%
% slct_avg.mask       = (slct_stat.mask ~= 0);
%
%
%
% list_chan{1} = {'MLC17', 'MLC25', 'MLF67', 'MLP44', 'MLP45', 'MLP56', 'MLP57', 'MLT14', 'MLT15', 'MLT25'};
%
% list_chan{2} = {'MRF67', 'MRT14', 'MRT15', 'MRT24', 'MRT25', 'MRT35'};
%
% list_chan{3} = {'MLC15', 'MLC16', 'MLC17', 'MLC23', 'MLC24', 'MLC25', 'MLC31', 'MLC32', 'MLF56', 'MLF66', 'MLF67', ...
%     'MLP23', 'MLP34', 'MLP35', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP55', 'MLP56', 'MLP57', 'MLT12', 'MLT13', ...
%     'MLT14', 'MLT15', 'MLT16', 'MLT22', 'MLT23', 'MLT24', 'MLT25', 'MLT33', 'MLT34', 'MLT35', 'MLT44'};
%
% list_chan{4} = {'MRC17', 'MRC25', 'MRF67', 'MRO14', 'MRP35', 'MRP44', 'MRP45', 'MRP55', 'MRP56', 'MRP57', 'MRT13', ...
%     'MRT14', 'MRT15', 'MRT16', 'MRT23', 'MRT24', 'MRT25', 'MRT26', 'MRT33', 'MRT34', 'MRT35', 'MRT36', 'MRT43', 'MRT44', 'MRT45'};
%
% list_chan{1}= {'MLC11', 'MLC12', 'MLC13', 'MLC14', 'MLC15', 'MLC16', 'MLC17', 'MLC21', 'MLC22', 'MLC23', 'MLC24', 'MLC25', 'MLC31', 'MLC32', 'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC61', 'MLC62', 'MLC63', 'MLF25', 'MLF34', 'MLF35', 'MLF44', 'MLF45', 'MLF46', 'MLF51', 'MLF52', 'MLF53', 'MLF54', 'MLF55', 'MLF56', 'MLF61', 'MLF62', 'MLF63', 'MLF64', 'MLF65', 'MLF66', 'MLF67', 'MLO11', 'MLO12', 'MLO13', 'MLO14', 'MLO21', 'MLO22', 'MLO23', 'MLO24', 'MLO31', 'MLO32', 'MLO33', 'MLO34', 'MLO41', 'MLO42', 'MLO43', 'MLO44', 'MLO51', 'MLO52', 'MLO53', 'MLP11', 'MLP12', 'MLP21', 'MLP22', 'MLP23', 'MLP31', 'MLP32', 'MLP33', 'MLP34', 'MLP35', 'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP51', 'MLP52', 'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT11', 'MLT12', 'MLT13', 'MLT14', 'MLT15', 'MLT16', 'MLT21', 'MLT22', 'MLT23', 'MLT24', 'MLT25', 'MLT26', 'MLT27', 'MLT31', 'MLT32', 'MLT33', 'MLT34', 'MLT35', 'MLT36', 'MLT37', 'MLT42', 'MLT43', 'MLT44', 'MLT45', 'MLT46', 'MLT47', 'MLT54', 'MLT55', 'MLT56', 'MLT57', 'MRC11', 'MRC12', 'MRC13', 'MRC14', 'MRC15', 'MRC16', 'MRC17', 'MRC21', 'MRC22', 'MRC23', 'MRC24', 'MRC25', 'MRC31', 'MRC32', 'MRC41', 'MRC42', 'MRC51', 'MRC52', 'MRC53', 'MRC54', 'MRC55', 'MRC61', 'MRC62', 'MRC63', 'MRF25', 'MRF34', 'MRF35', 'MRF44', 'MRF45', 'MRF46', 'MRF51', 'MRF52', 'MRF53', 'MRF54', 'MRF55', 'MRF56', 'MRF61', 'MRF62', 'MRF63', 'MRF64', 'MRF65', 'MRF66', 'MRF67', 'MRO11', 'MRO12', 'MRO13', 'MRO14', 'MRO21', 'MRO22', 'MRO23', 'MRO24', 'MRO31', 'MRO32', 'MRO33', 'MRO34', 'MRO41', 'MRO42', 'MRO43', 'MRO44', 'MRO51', 'MRO52', 'MRO53', 'MRP11', 'MRP12', 'MRP21', 'MRP22', 'MRP23', 'MRP31', 'MRP32', 'MRP33', 'MRP34', 'MRP35', 'MRP41', 'MRP42', 'MRP43', 'MRP44', 'MRP45', 'MRP51', 'MRP52', 'MRP53', 'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT11', 'MRT12', 'MRT13', 'MRT14', 'MRT15', 'MRT16', 'MRT21', 'MRT22', 'MRT23', 'MRT24', 'MRT25', 'MRT26', 'MRT27', 'MRT31', 'MRT32', 'MRT33', 'MRT34', 'MRT35', 'MRT36', 'MRT37', 'MRT42', 'MRT43', 'MRT44', 'MRT45', 'MRT46', 'MRT47', 'MRT53', 'MRT54', 'MRT55', 'MRT56', 'MRT57', 'MZC01', 'MZC02', 'MZC03', 'MZC04', 'MZF03', 'MZO01', 'MZO02', 'MZO03', 'MZP01'};
%
%
% for nchan = 1:length(list_chan)
%
%     figure;
%
%     for ngroup = 1:size(stat,1)
%
%         plimit                  = 0.11;
%         stat2plot               = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,plimit);
%
%         cfg                     = [];
%         cfg.channel             = list_chan{nchan};
%         cfg.avgoverchan         = 'yes';
%         nw_data                 = ft_selectdata(cfg,stat2plot);
%
%         subplot(1,2,1)
%         hold on
%         plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)));
%         xlim([nw_data.freq(1) nw_data.freq(end)])
%         ylim([0 0.5])
%
%         subplot(1,2,2)
%         hold on
%         plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)));
%         xlim([nw_data.time(1) nw_data.time(end)])
%         ylim([0 0.5])
%
%     end
%
%     legend({'Old','Young'})
%
% end