clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list           = [1:4 8:17];

for sb = 1:length(suj_list)
    
    
    suj                     = ['yc' num2str(suj_list(sb))] ;
    cond_main               = 'CnD';
    
    fname_in                = ['../data/paper_data/' suj '.' cond_main '.MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked.mat'];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    %     freq.label              = {'Occ Left','Occ Right','Aud Left','Aud Right'};
    
    freq                    = h_transform_freq(freq,{[1 2],[3 4]},{'Occipital Cortex','Auditory Cortex'});
    
    cfg                     = [];
    cfg.baseline            = [-0.6 -0.2];
    cfg.baselinetype        = 'relchange';
    freq                    = ft_freqbaseline(cfg, freq);
    
    cfg                     = [];
    cfg.latency             = [0.6 1];
    cfg.avgovertime         = 'yes';
    cfg.frequency           = [4 20];
    allsuj_data{sb,1}       = ft_selectdata(cfg, freq);
    
    data_matrix(sb,:,:)     = allsuj_data{sb,1}.powspctrm;
    
end

clearvars -except allsuj_data big_freq data_matrix

grand_average = ft_freqgrandaverage([],allsuj_data{:,1});

figure;
hold on;

for nchan = 1:length(grand_average.label)
    
    plot(grand_average.freq,grand_average.powspctrm(nchan,:),'LineWidth',4);
    xlim([4 20]);
    ylim([-0.2 0.2]);
    
end

hline(0,'--k');
legend(grand_average.label);
set(gca,'fontsize', 18)

data_mean   = squeeze(mean(data_matrix,1));
data_std    = squeeze(std(data_matrix,1));
data_sem    = data_std/sqrt(size(data_matrix,1));

figure;
hold on;

for nchan = 1:length(grand_average.label)
    
    list_color = 'rbgy';
    
    %     subplot(2,2,nchan)
    
    plot_mean_std(data_mean(nchan,:),data_sem(nchan,:),list_color(nchan),grand_average.freq);
    xlim([4 20]);
    ylim([-0.2 0.2]);
    
end

hline(0,'--k');
% legend(grand_average.label);
set(gca,'fontsize', 18)