clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

patient_list ;
suj_group{1}    = fp_list_meg;
suj_group{2}    = cn_list_meg;

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        cond_main                   = 'CnD';
        
        list_cue                    = {''};
        
        for ncue = 1:length(list_cue)
            
            ext_name                = 'waveletPOW.1t150Hz.m3000p3000.AvgTrials.mat';
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_cue{ncue} cond_main '.' ext_name];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq                            = ft_freqdescriptives([],freq);
            freq                            = rmfield(freq,'cfg');
            
            cfg                             = [];
            cfg.baseline                    = [-0.5 -0.2];
            cfg.baselinetype                = 'relchange';
            freq                            = ft_freqbaseline(cfg,freq);
            
            freq.freq                       = round(freq.freq);
            
            allsuj_data{ngrp}{sb,ncue}      = freq; clear tmp ;
            
        end
        
        clear freq
        
    end
end

clearvars -except allsuj_data ; clc ;

list_compare                = [1 2];

for ntest = 1:size(list_compare,1)
    
    ix_1                    = list_compare(ntest,1);
    ix_2                    = list_compare(ntest,2);
    
    nsubj                   = length(allsuj_data{ix_1});
    [~,neighbours]          = h_create_design_neighbours(nsubj,allsuj_data{ix_1}{1},'meg','t'); clc;
    
    cfg                     = [];
    
    cfg.latency             = [-0.2 2];
    cfg.frequency           = [15 40];
    
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
    
    cfg.minnbchan           = 2; 
    
    for ncue = 1:size(allsuj_data{1},2)
        
        stat{ntest,ncue}    = ft_freqstatistics(cfg, allsuj_data{ix_1}{:,ncue}, allsuj_data{ix_2}{:,ncue}); % young minus control
        
    end
end

for ntest = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ntest,ncue), p_val{ntest,ncue}]      = h_pValSort(stat{ntest,ncue});
    end
end


plimit                  = 0.1;
stat2plot               = h_plotStat(stat{1,1},0.00001,plimit);

cfg                     = [];
cfg.layout              = 'CTF275.lay';
cfg.marker              = 'off';
cfg.comment             = 'no';
cfg.zlim                = [-1 1];
ft_topoplotER(cfg,stat2plot);
        
for list_freq           = [7 11]
    
    
    i_1                     = 0;
    i_2                     = 8;
    i_3                     = 16;
    
    figure ;
    
    for tlist               = 0.4:0.2:1.8
        
        cfg                 = [];
        cfg.layout          = 'CTF275.lay';
        cfg.xlim            = [tlist tlist+0.2];
        cfg.ylim            = [list_freq list_freq+4];
        cfg.marker          = 'off';
        cfg.comment         = 'no';
        cfg.zlim            = [-3 3];
        
        i_1                 = i_1 + 1;
        subplot(3,8,i_1)
        ft_topoplotER(cfg,stat2plot);
        title(['Stat ' num2str(tlist*1000)]);
        
        cfg.zlim    = [-0.3 0.3];
        i_2         = i_2 + 1;
        subplot(3,8,i_2)
        ft_topoplotER(cfg,ft_freqgrandaverage([],allsuj_data{2}{:,1}));
        title(['Young ' num2str(tlist*1000)]);
        
        i_3         = i_3 + 1;
        subplot(3,8,i_3)
        ft_topoplotER(cfg,ft_freqgrandaverage([],allsuj_data{1}{:,1}));
        title(['Old ' num2str(tlist*1000)]);
        
    end
end

% for ntest = 1:size(stat,1)
%     for ncue = 1:size(stat,2)
%
%         zlimit                  = 2;
%
%         plimit                  = 0.1;
%
%         stat2plot               = h_plotStat(stat{ntest,ncue},0.00001,plimit);
%
%         subplot(2,2,1:2)
%
%         cfg         = [];
%         cfg.layout  = 'CTF275.lay';
%         cfg.xlim    = [0.5 0.8]; %0.5:0.1:2;
%         cfg.zlim    = [-zlimit zlimit];
%         cfg.marker  = 'off';
%         cfg.comment = 'no';
%         ft_topoplotER(cfg,stat2plot);
%
%         title(list_test{ntest})
%
%     end
% end
%
% list_chan{1}    = {'MLC41', 'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC61', 'MLC62', 'MLC63', 'MLP11', ...
%     'MLP12', 'MLP21', 'MLP22', 'MLP32', 'MRC41', 'MRC52', 'MRC53', 'MRC54', 'MRC55', 'MRC61', 'MRC62', ...
%     'MRC63', 'MRP11', 'MRP12', 'MRP21', 'MRP22', 'MRP32'} ;
%
% list_chan{2}    = {'MRC15', 'MRC16', 'MRC17', 'MRC24', 'MRC25', 'MRF56', 'MRF65', 'MRF66', 'MRF67', ...
%     'MRP35', 'MRP44', 'MRP45', 'MRP56', 'MRP57', 'MRT12', 'MRT13', 'MRT14', 'MRT15', 'MRT22', ...
%     'MRT23', 'MRT24', 'MRT25', 'MRT34', 'MRT35'} ;
%
% list_chan{3}     = {'MLO31', 'MLO32', 'MLO41', 'MLO42', 'MLO43', 'MLO51', 'MLO52', 'MRO23', 'MRO24', 'MRO32', 'MRO33', 'MRO34', 'MRO43', 'MRO44', 'MRO53'};
%
% i                = 0;
%
% for nlist = 1:length(list_chan)
%
%     i               = i + 1 ;
%     subplot(3,4,i)
%
%     new_topo                = stat2plot;
%     new_topo.powspctrm(:)   = 0;
%
%     cfg                     = [];
%     cfg.layout              = 'CTF275.lay';
%     cfg.marker              = 'off';
%     cfg.comment             = 'no';
%     cfg.highlight           = 'on';
%     cfg.highlightchannel    =  list_chan{nlist};
%     cfg.highlightsymbol     = 'x';
%     cfg.highlightsize       = 10;
%     ft_topoplotER(cfg,new_topo);
%
%     cfg             = [];
%     cfg.channel     = list_chan{nlist};
%     cfg.avgoverchan = 'yes';
%     nw_data         = ft_selectdata(cfg,stat2plot);
%
%     i               = i + 1 ;
%     subplot(3,4,i)
%
%     cfg             = [];
%     cfg.channel     = list_chan{nlist};
%     cfg.zlim        = [-3 3];
%     ft_singleplotTFR(cfg,stat2plot);
%     title('');
%     vline(0,'--k');
%     vline(1.2,'--k');
%
%     i               = i + 1 ;
%     subplot(3,4,i)
%
%     plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)),'LineWidth',3);
%     xlim([nw_data.freq(1) nw_data.freq(end)])
%     ylim([-3 0])
%     vline(0,'--k');
%     vline(1.2,'--k');
%
%     i               = i + 1 ;
%     subplot(3,4,i)
%
%     plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)),'LineWidth',3);
%     xlim([nw_data.time(1) nw_data.time(end)])
%     ylim([-3 0])
%     vline(0,'--k');
%     vline(1.2,'--k');
%
% end
%
% plimit                  = 0.1;
% stat2plot               = h_plotStat(stat{1,1},0.00001,plimit);
%
% i                       = 0;
%
% for tlist = 0.5:0.1:2
%
%
%     cfg         = [];
%     cfg.layout  = 'CTF275.lay';
%     cfg.xlim    = [tlist tlist+0.1];
%     cfg.marker  = 'off';
%     cfg.comment = 'no';
%     cfg.zlim    = [-3 3];
%
%     i           = i + 1;
%     subplot(4,4,i)
%
%     ft_topoplotER(cfg,stat2plot);
%
%     for ngroup = 1:2
%
%         cfg.zlim    = [-3 3];
%         i           = i + 1;
%         subplot(4,4,i)
%         ft_topoplotER(cfg,ft_freqgrandaverage([],allsuj_data{ngroup}{:,1}));
%     end
%
% end
%
% zlimit                  = 2;
% plimit                  = 0.05;
%
% stat2plot               = h_plotStat(stat{ncue},0.00001,plimit);
%
% cfg         = [];
% cfg.ylim    = [11 15];
% cfg.xlim    = [0.6 1];
% cfg.layout  = 'CTF275.lay';
% cfg.zlim    = [-zlimit zlimit];
% cfg.marker  = 'off';
% cfg.comment = 'no';
% cfg.colorbar  = 'yes';
% subplot(1,3,1)
% ft_topoplotER(cfg,stat2plot); title('Stat Young v Old');
% zlimit       = 0.2;
% cfg.zlim    = [-zlimit zlimit];
% subplot(1,3,2)
% ft_topoplotER(cfg,ft_freqgrandaverage([],allsuj_data{2}{:,1})); title('Young');
% subplot(1,3,3)
% ft_topoplotER(cfg,ft_freqgrandaverage([],allsuj_data{1}{:,1})); title('Old');
%
%
%
% cfg             = [];
% cfg.channel     = 'all';
% cfg.zlim        = [-zlimit zlimit];
% ft_singleplotTFR(cfg,stat2plot) ; title('');
%
% cfg             = [];
% cfg.channel     = {'MLC13', 'MLC21', 'MLC22', 'MLC31', 'MLC41', 'MLC51', 'MLC52', 'MLC53', 'MLC61', 'MRC51', 'MRC61', 'MZC02'};
% cfg.avgoverchan = 'yes';
% nw_data         = ft_selectdata(cfg,stat2plot);
%
% subplot(2,2,3)
% plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)));
% xlim([nw_data.freq(1) nw_data.freq(end)])
% ylim([0 0.7])
% vline(70,'--k');
% vline(90,'--k');
%
% cfg             = [];
% cfg.frequency   = [70 90];
% cfg.avgoverfreq = 'yes';
% nw_data         = ft_selectdata(cfg,nw_data);
%
% subplot(2,2,4)
% plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)));
% xlim([nw_data.time(1) nw_data.time(end)])
% vline(0.35,'--k');
% vline(0.65,'--k');