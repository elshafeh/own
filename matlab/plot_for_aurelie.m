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
        ext_name2               = 'NewAVBroad.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrialsMinEvoked10MStep80Slct';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        freq                        = ft_freqdescriptives([],freq);
        
        %         new_chan_list           = {'Left Visual Cortex','Right Visual Cortex','Left Auditory Cortex','Right Auditory Cortex'};
        %         freq                    = h_transform_freq(freq,{[1 3 5],[2 4 6],[7 9 11],[8 10 12]},new_chan_list);
        
        new_chan_list               = {'Visual Cortex','Auditory Cortex'};
        freq                        = h_transform_freq(freq,{[1 3 5 2 4 6],[7 9 11 8 10 12]},new_chan_list);
        
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj_data{ngroup}{sb,1}   = ft_freqbaseline(cfg,freq);
        
    end
end

clearvars -except allsuj_data ;

figure;

for nchan = 1:2
    
    %     subplot(1,2,nchan);
    hold on;
    
    y_lim                           = [-0.4 0.4];
    
    yng_gavg                        = ft_freqgrandaverage([],allsuj_data{2}{:,1});
    old_gavg                        = ft_freqgrandaverage([],allsuj_data{1}{:,1});
    
    cfg                             = [];
    cfg.latency                     = [-0.2 1.2];
    cfg.frequency                   = [11 15];
    cfg.avgoverfreq                 = 'yes';
    slct_yng_gavg                   = ft_selectdata(cfg,yng_gavg);
    slct_old_gavg                   = ft_selectdata(cfg,old_gavg);
    
    if nchan == 1
        plot(slct_yng_gavg.time,squeeze(slct_yng_gavg.powspctrm(nchan,:,:)),'b','LineWidth',2); xlim([-0.1 1.2]); ylim(y_lim);
        plot(slct_old_gavg.time,squeeze(slct_old_gavg.powspctrm(nchan,:,:)),'--b','LineWidth',2); xlim([-0.1 1.2]);ylim(y_lim);
    else
        plot(slct_yng_gavg.time,squeeze(slct_yng_gavg.powspctrm(nchan,:,:)),'r','LineWidth',2); xlim([-0.1 1.2]); ylim(y_lim);
        plot(slct_old_gavg.time,squeeze(slct_old_gavg.powspctrm(nchan,:,:)),'--r','LineWidth',2); xlim([-0.1 1.2]);ylim(y_lim);
    end
    
    %     yng_gavg                        = ft_freqgrandaverage([],allsuj_data{2}{:,1});
    %     old_gavg                        = ft_freqgrandaverage([],allsuj_data{1}{:,1});
    %
    %     cfg                             = [];
    %     cfg.latency                     = [-0.2 1.2];
    %     cfg.frequency                   = [11 15];
    %     cfg.avgoverfreq                 = 'yes';
    %     slct_yng_gavg                   = ft_selectdata(cfg,yng_gavg);
    %     slct_old_gavg                   = ft_selectdata(cfg,old_gavg);
    %
    %     plot(slct_yng_gavg.time,squeeze(slct_yng_gavg.powspctrm(nchan,:,:)),'r','LineWidth',2); xlim([-0.1 1.2]); ylim(y_lim);
    %     plot(slct_old_gavg.time,squeeze(slct_old_gavg.powspctrm(nchan,:,:)),'--r','LineWidth',2); xlim([-0.1 1.2]);ylim(y_lim);
    
end

legend({'Young Visual Cortex','Old Visual Cortex','Young Auditory Cortex','Old Auditory Cortex'});
