clear ; clc ;
addpath(genpath('../fieldtrip-20151124/'));
addpath('DrosteEffect-BrewerMap-b6a6efc/'); 
% plot per subject

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj         = suj_list{sb};
    
    ext_name    = 'BroadAud5perc.1t110Hz.m200p400msCov.waveletPOW.5t110Hz.m200p600.MinEvokedKeepTrials';
    fname_in    = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.DIS.' ext_name '.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    cfg                 = [];
    cfg.latency         = [-0.1 0.4];
    cfg.frequency       = [60 100];
    freq                = ft_selectdata(cfg,freq);
    
    data                = squeeze(freq.powspctrm)./1e22;
    
    lm_1                = find(round(freq.freq) == round(60));
    lm_2                = find(round(freq.freq) == round(100));
    
    data                = squeeze(mean(data(:,lm_1:lm_2,:),2));
    
    subplot(3,7,sb)
    %     figure;
    
    mean_data           = mean(mean(data));
    std_data            = std(std(data));

    plot_x_axis         = 1:size(data,1);
    plot_y_axis         = freq.time;
    
    imagesc(plot_y_axis,plot_x_axis,data);
    
    xlim([plot_y_axis(1) plot_y_axis(end)]); clear plot_y_axis plot_y_axis;
    
    vline(0,'--k');
    vline(0.1,'--k');
    vline(0.2,'--k');
    vline(0.3,'--k');

    axis xy;
    
    if sb == 18
        xlabel('Time (ms): averaged between 60 and 100Hz');
    end
    
    if  sb == 8
        ylabel('Trials');
    end
    
    caxis([0 3]) ; % [mean_data-std_data mean_data+std_data]);
    
    set(gca,'YDir','normal')
    colormap(brewermap(256, '*RdYlBu'));
    
    
    clearvars -except sb suj_list
    
end
