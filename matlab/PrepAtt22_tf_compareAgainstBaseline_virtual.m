clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:22);
% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

% suj_group{1}          = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        
        cond_main                   = 'nDT';
        list_cue                    = {'MinEvokedAvgTrials.mat','eEvokedAvgTrials.mat','avgPeTfrAvgTrials.mat'};
        
        for ncue = 1:length(list_cue)
            
            ext_virt            = '.BroadAud5perc.50t110Hz.m2000p800msCov.waveletPOW.50t109Hz.m2000p2000.';
            dir_data            = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/'];
            
            fname_in            = [dir_data suj '.' cond_main ext_virt list_cue{ncue}];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            if strcmp(freq.dimord,'rpt_chan_freq_time')
                freq                                = ft_freqdescriptives([],freq);
            end
            
            %             [tmp{1},tmp{2}]                         = h_prepareBaseline(freq,[-1.6 -1.4],[50 110],[-0.1 0.5],'no');
            [tmp{1},tmp{2}]                         = h_prepareBaseline(freq,[-0.4 -0.2],[50 110],[-0.1 0.5],'no');

            allsuj_activation{ngroup}{sb,ncue}      = tmp{1};
            allsuj_baselineRep{ngroup}{sb,ncue}     = tmp{2};
            
        end
    end
end

clearvars -except allsuj_* list_cue;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                        = size(allsuj_activation{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        
        cfg.correctm            = 'cluster'; % 'bonferroni' ; % 
        
        cfg.neighbours          = neighbours;
        
        %         cfg.channel             = [3 4];
        %         cfg.latency             = [1 1.6];
        %         cfg.frequency           = [60 100];
        %         cfg.avgovertime         = 'yes';
        
        %         cfg.avgoverfreq         = 'yes';
        %         cfg.avgoverchan         = 'yes';
        
        cfg.clusteralpha        = 0.05;
        cfg.alpha               = 0.025;
        cfg.minnbchan           = 0;
        
        cfg.tail                = 1;
        cfg.clustertail         = 1;
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ncue}      = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        stat{ngroup,ncue}      = rmfield(stat{ngroup,ncue},'cfg');
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue),p_val{ngroup,ncue}]      = h_pValSort(stat{ngroup,ncue});
    end
end

p_limit = 0.05;

figure;
i = 0 ;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        s2plot          = stat{ngroup,ncue};
        s2plot.mask     = s2plot.prob < p_limit;
        
        for nchan = 1:length(s2plot.label);
            
            subplot_row         = 3;
            subplot_col         = 6;
            
            i                   = i + 1 ;
            
            subplot(subplot_row,subplot_col,i)
            
            cfg                 = [];
            cfg.channel         = nchan;
            cfg.parameter       = 'stat';
            cfg.maskparameter   = 'mask';
            cfg.maskstyle       = 'opacity';
            cfg.maskalpha       = 0.6;
            cfg.zlim            = [-5 5];
            cfg.colorbar        = 'no';
            ft_singleplotTFR(cfg,s2plot);
            title([list_cue{ncue} ' ' s2plot.label{nchan}]);
            
        end
    end
end

% for ngroup = 1:size(stat,1)
%     for nchan = 1:length(stat{ngroup,ncue}.label)
%         for ncue = 1:size(stat,2)
%
%
%             stat_to_plot       = stat{ngroup,ncue};
%             stat_to_plot.mask  = stat_to_plot.prob < p_limit;
%
%             i = i + 1;
%
%             [x_ax,y_ax,z_ax]                = size(stat_to_plot.stat);
%
%             if y_ax == 1
%
%                 subplot(2,2,2)
%                 plot(stat_to_plot.time,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
%                 ylim([0 3.5]);
%                 xlim([stat_to_plot.time(1) stat_to_plot.time(end)])
%
%             elseif z_ax == 1
%
%                 plot(stat_to_plot.freq,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
%                 ylim([-3 3]);
%                 xlim([stat_to_plot.freq(1) stat_to_plot.freq(end)])
%
%             else
%
%                 gavg_act                = ft_freqgrandaverage([],allsuj_activation{1}{:,1});
%                 gavg_bsl                = ft_freqgrandaverage([],allsuj_baselineRep{1}{:,1});
%
%                 cfg                     = [];
%                 cfg.avgoverchan         = 'yes';
%                 cfg.latency             = [stat_to_plot.time(1) stat_to_plot.time(end)];
%                 cfg.frequency           = [stat_to_plot.freq(1) stat_to_plot.freq(end)];
%
%                 gavg_act                = ft_selectdata(cfg,gavg_act);
%                 gavg_bsl                = ft_selectdata(cfg,gavg_bsl);
%
%                 new_freq                = gavg_act;
%                 new_freq.powspctrm      = (gavg_act.powspctrm-gavg_bsl.powspctrm)./gavg_bsl.powspctrm;
%                 new_freq.mask           = stat_to_plot.mask;
%
%                 ix                      = find(round(new_freq.time,2) == round(1,2));
%                 new_freq.mask(:,:,1:ix) = 0;
%
%                 cfg                     = [];
%                 cfg.channel             = nchan;
%                 cfg.parameter           = 'powspctrm';
%                 cfg.maskparameter       = 'mask';
%                 cfg.maskstyle           = 'outline';
%                 cfg.zlim                = [-0.03 0.03];
%
%                 subplot(2,2,1)
%                 ft_singleplotTFR(cfg,new_freq);
%                 vline(1.2,'--b','');
%
%                 subplot(2,2,2)
%                 cfg.zlim                = [-3 3];
%                 cfg.parameter           = 'stat';
%                 ft_singleplotTFR(cfg,stat_to_plot);
%                 vline(1.2,'--b','');
%
%                 list_channel            = 'all';
%
%                 nw_data                 = h_plotStat(stat_to_plot,0.000000000000000000000000000001,0.05);
%                 av_lim                  = 1.6;
%
%                 subplot(2,2,3)
%                 hold on
%                 plot(nw_data.freq,squeeze(nanmean(nw_data.powspctrm,3)));
%                 xlim([nw_data.freq(1) nw_data.freq(end)])
%                 ylim([0 av_lim])
%
%                 subplot(2,2,4)
%                 hold on
%                 plot(nw_data.time,squeeze(nanmean(nw_data.powspctrm,2)));
%                 xlim([nw_data.time(1) nw_data.time(end)])
%                 ylim([0 av_lim])
%
%
%             end
%
%                         title([list_cue{ncue} 'CnD ' stat_to_plot.label{nchan} ' p = ' num2str(min_p(ngroup,ncue))])
%
%         end
%     end
% end
%
% gavg_act                = ft_freqgrandaverage([],allsuj_activation{1}{:,1});
% gavg_bsl                = ft_freqgrandaverage([],allsuj_baselineRep{1}{:,1});
%
% cfg                     = [];
% cfg.avgoverchan         = 'yes';
% cfg.latency             = [stat_to_plot.time(1) stat_to_plot.time(end)];
% cfg.frequency           = [stat_to_plot.freq(1) stat_to_plot.freq(end)];
%
% gavg_act                = ft_selectdata(cfg,gavg_act);
% gavg_bsl                = ft_selectdata(cfg,gavg_bsl);
%
% new_freq                = gavg_act;
% new_freq.powspctrm      = (gavg_act.powspctrm-gavg_bsl.powspctrm)./gavg_bsl.powspctrm;
%
% cfg                     = [];
% cfg.channel             = nchan;
% cfg.parameter           = 'powspctrm';
% cfg.maskparameter       = 'mask';
% cfg.maskstyle           = 'outline';
% cfg.zlim                = [-0.03 0.03];
%
% subplot(2,2,1)
% ft_singleplotTFR(cfg,new_freq);
% vline(1.2,'--b','');
% vline(1.3,'--b','');
% vline(1.45,'--b','');
% hline(60,'--b','');
% hline(100,'--b','');