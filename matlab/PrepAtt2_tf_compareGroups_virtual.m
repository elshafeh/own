clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group       = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        ext_name2               = 'AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';
        
        fname_in                = ['../data/ageing_data/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        freq                        = h_transform_freq(freq,{[1 2],[3 4],[5 6]},{'Visual Cortex','Auditory Cortex','Motor Cortex'});
        
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj_data{ngroup}{sb,1}   = ft_freqbaseline(cfg,freq);
        
        %         freq.powspctrm              = freq.powspctrm / 1e23;
        %         allsuj_data{ngroup}{sb,1}   = freq;
        
        clc;
        
    end
    
end

clearvars -except allsuj_data list_ix

list_freq                       = [7 11; 11 15];
time_lim                        = [0.6 1];

for nfreq = 1:2
    
    freq_lim                    = list_freq(nfreq,:);
    
    for ncue = 1:size(allsuj_data{1},2)
        
        nsubj                   = size(allsuj_data{1},1);
        
        [~,neighbours]          = h_create_design_neighbours(nsubj,allsuj_data{1}{1},'virt','t'); clc;
        
        cfg                     = [];
        cfg.statistic           = 'indepsamplesT'; cfg.method = 'montecarlo'; cfg.correctm = 'cluster'; cfg.clusterstatistic = 'maxsum';
        
        cfg.avgoverfreq         = 'yes';
        
        cfg.clusteralpha        = 0.05;
        cfg.tail                = 0; cfg.clustertail         = 0;
        cfg.alpha               = 0.025; cfg.numrandomization    = 1000;
        
        cfg.design              = [ones(1,nsubj) ones(1,nsubj)*2];
        cfg.minnbchan           = 0;
        cfg.neighbours          = neighbours;
        
        cfg.frequency           = freq_lim;
        cfg.latency             = time_lim;
        
        stat{ncue,nfreq}        = ft_freqstatistics(cfg,allsuj_data{2}{:,ncue}, allsuj_data{1}{:,ncue});
        
    end
end

for ncue = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        [min_p(ncue,nfreq),p_val{ncue,nfreq}] = h_pValSort(stat{ncue,nfreq});
    end
end

clearvars -except allsuj_data list_ix stat min_p p_val

figure;
i = 0 ;

for nfreq = 1:size(stat,2)
    for ncue = 1:size(stat,1)
        
        list_freq                           = [7 11; 11 15];
        freq_lim                            = list_freq(nfreq,:);
        time_lim                            = [-0.1 1.2];

        for nchan = 1:length(stat{ncue}.label)
            
            i                               = i + 1 ;
            
            plimit                          = 0.02;
            s2plot                          = stat{ncue,nfreq};
            s2plot.mask                     = s2plot.prob < plimit;
            
            subplot_row                     = 2 ;
            subplot_col                     = 3 ;
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.p_threshold                 = plimit;
            cfg.lineWidth                   = 2;
            cfg.time_limit                  = time_lim;
            cfg.z_limit                     = [-0.35 0.35];
            cfg.avglimit                    = freq_lim;
            cfg.legend                      = {'Old','Young'};
            
            subplot(subplot_row,subplot_col,i)
            h_plotSingleTFstat_selectChannel(cfg,s2plot,ft_freqgrandaverage([],allsuj_data{1}{:,ncue}),ft_freqgrandaverage([],allsuj_data{2}{:,ncue}))
            
            title([s2plot.label{nchan}],'FontSize',14)
            
        end
    end
end

% for ncue = 1:length(stat)
%
%     figure;
%     i    = 0;
%
%     for nchan = [1 3 5 2 4 6] %1:length(stat{ncue}.label)
%
%         i                               = i + 1 ;
%
%         plimit                          = 0.11;
%         s2plot                          = stat{ncue};
%         s2plot.mask                     = s2plot.prob < plimit;
%
%         subplot_row                     = 2 ;
%         subplot_col                     = 3 ;
%
%         cfg                             = [];
%         cfg.channel                     = nchan;
%         cfg.p_threshold                 = plimit;
%         cfg.lineWidth                   = 2;
%         cfg.time_limit                  = time_lim;
%         cfg.z_limit                     = [-0.35 0.35];
%         cfg.avglimit                    = freq_lim;
%         cfg.legend                      = {'Old','Young'};
%
%         subplot(subplot_row,subplot_col,i)
%         h_plotSingleTFstat_selectChannel(cfg,s2plot,ft_freqgrandaverage([],allsuj_data{1}{:,ncue}),ft_freqgrandaverage([],allsuj_data{2}{:,ncue}))
%
%         title([s2plot.label{nchan}],'FontSize',14)
%
%
%     end
% en
%
% cfg                             = [];
% cfg.channel                     = nchan;
% cfg.parameter                   = 'stat';
% cfg.maskparameter               = 'mask';
% cfg.maskstyle                   = 'outline';
% cfg.colorbar                    = 'yes';
% cfg.colormap                    = redblue;
% cfg.zlim                        = [-3 3];
% subplot(subplot_row,subplot_col,i)
% ft_singleplotTFR(cfg,s2plot);
% title([s2plot.label{nchan}],'FontSize',14)
% %         colormap(redblue)
%
% cfg                             = [];
% cfg.channel                     = nchan;
% cfg.colorbar                    = 'yes';
% cfg.colormap                    = jet;
% cfg.zlim                        = [2 16] ; %[-0.2 0.2];
% cfg.xlim                        = [s2plot.time(1) s2plot.time(end)];
% cfg.ylim                        = [s2plot.freq(1) s2plot.freq(end)];
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% ft_singleplotTFR(cfg,ft_freqgrandaverage([],allsuj_data{1}{:,ncue})); title('Old','FontSize',14);
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
%
% ft_singleplotTFR(cfg,ft_freqgrandaverage([],allsuj_data{2}{:,ncue})); title('Young','FontSize',14);
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% data = squeeze(mean(s2plot.stat(nchan,:,:),2)) .* squeeze(mean(s2plot.mask(nchan,:,:),2));
% plot(s2plot.time,data);
% xlim([s2plot.time(1) s2plot.time(end)])
% %         ylim([0 2])
% title('Avg Over Frequency','FontSize',14);
%
% i                               = i + 1 ;
% subplot(subplot_row,subplot_col,i)
% data = squeeze(mean(s2plot.stat(nchan,:,:),3)) .* squeeze(mean(s2plot.mask(nchan,:,:),3));
% plot(s2plot.freq,data);
% xlim([s2plot.freq(1) s2plot.freq(end)])
% %         ylim([0 2])
% title('Avg Over Time','FontSize',14);
%
% %         mx_data = find(data==max(data));
% %         vline(s2plot.freq(mx_data),'--k',[num2str(round(s2plot.freq(mx_data))) 'Hz'])
%
