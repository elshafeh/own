clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'old','young'};

for ngroup = 1:length(lst_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        
        %         if ngroup == 1
        %             ext_file                = '14AudOc';
        %         else
        %             ext_file                = '14AudYc';
        %         end
        
        ext_file                = '14AudYc';
        ext_name2               = [ext_file '.1t20Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvokedAllTrials'];
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        %         cfg                         = [];
        %         cfg.channel                 = 3:6;
        %         freq                        = ft_selectdata(cfg,freq);
        %         freq                        = ft_freqdescriptives([],freq);
        
        %         new_chan_list           = {'Visual Cortex','Auditory Cortex'};
        %         freq                    = h_transform_freq(freq,{[3 4],[5 6]},new_chan_list);
        
        %         new_chan_list               = {'Visual Cortex','Auditory Cortex'};
        %         freq                        = h_transform_freq(freq,{[1 3 5 2 4 6],[7 9 11 8 10 12]},new_chan_list);
        
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj_data{ngroup}{sb,1}   = ft_freqbaseline(cfg,freq);
        
        %         allsuj_data{ngroup}{sb,1}   = freq;

        
        clc;
        
    end
    
end

clearvars -except allsuj_data list_ix

freq_lim                        = [1 20];
time_lim                        = [-1 1.2];

for ncue = 1:size(allsuj_data{1},2)
    
    nsubj                   = size(allsuj_data{1},1);
    
    [~,neighbours]          = h_create_design_neighbours(nsubj,allsuj_data{1}{1},'virt','t'); clc;
    
    cfg                     = [];
    cfg.statistic           = 'indepsamplesT';
    cfg.method              = 'montecarlo';
    
    cfg.correctm            = 'cluster';
    
    cfg.clusteralpha        = 0.05;
    cfg.clusterstatistic    = 'maxsum';
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.alpha               = 0.025;
    cfg.numrandomization    = 1000;
    cfg.design              = [ones(1,nsubj) ones(1,nsubj)*2];
    cfg.minnbchan           = 0;
    cfg.neighbours          = neighbours;
    
    cfg.frequency           = freq_lim;
    cfg.latency             = time_lim;
    
    %     cfg.avgoverfreq         = 'yes';
    
    stat{ncue}              = ft_freqstatistics(cfg,allsuj_data{2}{:,ncue}, allsuj_data{1}{:,ncue});
    
end

for ncue = 1:length(stat)
    [min_p(ncue),p_val{ncue}] = h_pValSort(stat{ncue});
end

clearvars -except allsuj_data list_ix min_p p_val stat

for ncue = 1:length(stat)
    
    figure;
    
    i         = 0;
    
    for nchan = 1:length(stat{ncue}.label)
        
        i                               = i + 1 ;
        
        s2plot                          = stat{ncue};
        
        subplot_row                     = 2 ;
        subplot_col                     = 1 ;
        
        subplot(subplot_row,subplot_col,i)
        
        s2plot.mask                     = s2plot.prob < 0.1;
        
        cfg                             = [];
        cfg.channel                     = nchan;
        cfg.parameter                   = 'stat';
        cfg.maskparameter               = 'mask';
        cfg.maskstyle                   = 'outline';
        cfg.colorbar                    = 'yes';
        cfg.zlim                        = [-10 10];
        ft_singleplotTFR(cfg,s2plot);
        
        colormap(redblue)
        
        %         cfg                             = [];
        %         cfg.channel                     = nchan;
        %         cfg.p_threshold                 = 0.11;
        %         cfg.lineWidth                   = 3;
        %         cfg.time_limit                  = [-0.2 2];
        %         cfg.z_limit                     = [-0.4 0.4];
        %         cfg.legend                      = {'Old CnD','Young CnD'};
        %         cfg.avgover                     = 'freq';
        %         cfg.dim_list                    = freq_lim;
        
        %         h_plotStatAvgOverDimension(cfg,s2plot,ft_freqgrandaverage([],allsuj_data{1}{:,ncue}),ft_freqgrandaverage([],allsuj_data{2}{:,ncue}))
        
        %         hline(0,'-k');
        
        title([s2plot.label{nchan}]); % ' ' num2str(round(min(stat{ncue}.prob(nchan,:,:)),3))])
        
    end
end


% cfg                             = [];
% cfg.channel                     = nchan;
% cfg.parameter                   = 'stat';
% cfg.maskparameter               = 'mask';
% cfg.maskstyle                   = 'outline';
% cfg.colorbar                    = 'yes';
% cfg.zlim                        = [-3 3];
% ft_singleplotTFR(cfg,s2plot);
% yng_gavg                        = ft_freqgrandaverage([],allsuj_data{2}{:,ncue});
% old_gavg                        = ft_freqgrandaverage([],allsuj_data{1}{:,ncue});
%
% cfg                             = [];
% cfg.latency                     = time_lim;
% cfg.frequency                   = freq_lim;
% yng_gavg                        = ft_selectdata(cfg,yng_gavg);
% old_gavg                        = ft_selectdata(cfg,old_gavg);
%
% yng_gavg.mask                   = s2plot.mask;
% old_gavg.mask                   = s2plot.mask;
%
% cfg                             = [];
% cfg.channel                     = nchan;
% cfg.parameter                   = 'powspctrm';
% cfg.maskparameter               = 'mask';
% cfg.xlim                        = time_lim;
% cfg.ylim                        = freq_lim;
% cfg.maskstyle                   = 'outline';
% cfg.maskstyle                   = 'opacity';
% cfg.maskalpha                   = 0.7;
% cfg.colorbar                    = 'yes';
% cfg.zlim                        = [-0.3 0.3];
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% ft_singleplotTFR(cfg,yng_gavg);
% title('Young Participants')
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% ft_singleplotTFR(cfg,old_gavg);
% title('Old Participants')
%
% pow_to_plot                     = s2plot.mask .* s2plot.stat;
%
% yng_gavg.mask                   = s2plot.mask;
% old_gavg.mask                   = s2plot.mask;
%
% cfg                             = [];
% cfg.channel                     = nchan;
% cfg.parameter                   = 'powspctrm';
% cfg.maskparameter               = 'mask';
% cfg.xlim                        = time_lim;
% cfg.ylim                        = freq_lim;
% cfg.maskstyle                   = 'opacity';
% cfg.maskalpha                   = 0.3;
% cfg.colorbar                    = 'no';
% cfg.zlim                        = [-0.3 0.3];
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% ft_singleplotTFR(cfg,yng_gavg);
% title('Young')
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% ft_singleplotTFR(cfg,old_gavg);
% title('Old')
%
% avrg_lim                        = [0 4];
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% plot(s2plot.freq,squeeze(mean(pow_to_plot(nchan,:,:),3)),'LineWidth',2); xlim(freq_lim); ylim(avrg_lim);
% title('Av Time')
% vline(14,'--r');
% vline(26,'--r');
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% plot(s2plot.time,squeeze(mean(pow_to_plot(nchan,:,:),2))); xlim(time_lim); ylim(avrg_lim);
% title('Av Freq')
%
% yng_gavg                        = ft_freqgrandaverage([],allsuj_data{2}{:,ntest});
% old_gavg                        = ft_freqgrandaverage([],allsuj_data{1}{:,ntest});
%
% cfg                             = [];
% cfg.latency                     = time_lim;
% cfg.avgoverfreq = 'yes';
% cfg.avgovertime = 'yes';
% cfg.frequency                   = freq_lim;
% yng_gavg                        = ft_selectdata(cfg,yng_gavg);
% old_gavg                        = ft_selectdata(cfg,old_gavg);

% plot(yng_gavg.time,squeeze(yng_gavg.powspctrm(nchan,:,:),'LineWidth',2);


% yng_gavg.powspctrm              = yng_gavg.powspctrm .* s2plot.mask ;
% old_gavg.powspctrm              = old_gavg.powspctrm .* s2plot.mask ;
%
% lmf1                            = find(round(yng_gavg.freq) == round(10));
% lmf2                            = find(round(yng_gavg.freq) == round(17));
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% hold on
% plot(yng_gavg.time,squeeze(mean(yng_gavg.powspctrm(nchan,lmf1:lmf2,:),2)),'LineWidth',2);
% plot(old_gavg.time,squeeze(mean(old_gavg.powspctrm(nchan,lmf1:lmf2,:),2)),'LineWidth',2);
% xlim(time_lim)
% ylim([-0.6 0.6])
% title('Average Across 10 - 17 Hz')
% legend({'Old','Young'});
% vline(1.2,'--g','Cue Onset');
%
% lmf1                            = find(round(yng_gavg.freq) == round(20));
% lmf2                            = find(round(yng_gavg.freq) == round(30));
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% hold on
% plot(yng_gavg.time,squeeze(mean(yng_gavg.powspctrm(nchan,lmf1:lmf2,:),2)),'LineWidth',2);
% plot(old_gavg.time,squeeze(mean(old_gavg.powspctrm(nchan,lmf1:lmf2,:),2)),'LineWidth',2);
% xlim(time_lim)
% ylim([-0.6 0.6])
% title('Average Across 20 - 30 Hz')
% legend({'Old','Young'});
% vline(1.2,'--g','Cue Onset');