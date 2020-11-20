clear ; clc ;
addpath(genpath('../fieldtrip-20151124/'));
addpath('DrosteEffect-BrewerMap-b6a6efc/'); 
% plot per subject

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

big_data        = [];
big_max         = [];

for sb = 1:length(suj_list)
    
    suj         = suj_list{sb};
    
    ext_name    = 'BroadAud5perc.1t110Hz.m200p400msCov.waveletPOW.5t110Hz.m200p600.MinEvokedKeepTrials';
    fname_in    = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.DIS.' ext_name '.mat'];
    
    %     ext_name    = 'BroadAud5perc.1t110Hz.m2000p800msCov.waveletPOW.30t110Hz.m2000p1000.MinEvokedKeepTrials';
    %     fname_in    = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.nDT.' ext_name '.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    %     lm_1                = find(round(freq.time,3) == round(-1.6,3));
    %     lm_2                = find(round(freq.time,3) == round(-1.4,3));
    %
    %     bsl                 = squeeze(mean(freq.powspctrm(:,:,:,lm_1:lm_2),4));
    %     bsl                 = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
    %
    %     freq.powspctrm      = (freq.powspctrm -bsl)./ bsl;
    
    freq_choose         = [20 110];
    
    cfg                 = [];
    cfg.latency         = [0.1 0.3];
    cfg.frequency       = freq_choose;
    freq                = ft_selectdata(cfg,freq);
    
    data                = squeeze(freq.powspctrm); % ./1e22; % 
    
    %     lm_1                = find(round(freq.time,3) == round(0.1,3));
    %     lm_2                = find(round(freq.time,3) == round(0.3,3));
    
    lm_1                = find(round(freq.time,3) == round(0.1,3));
    lm_2                = find(round(freq.time,3) == round(0.3,3));
    
    data                = squeeze(nanmean(data(:,:,lm_1:lm_2),3));
    data                = data/1e+22;
    
    subplot(3,7,sb)
    
    mean_data           = nanmean(nanmean(data));
    std_data            = nanstd(nanstd(data));

    plot_x_axis         = 1:size(data,1);
    plot_y_axis         = freq.freq;
    
    imagesc(plot_y_axis,plot_x_axis,data);
    
    xlim([plot_y_axis(1) plot_y_axis(end)]);
    
    vline(50,'--k');
    vline(60,'--k');
    vline(70,'--k');
    vline(80,'--k');
    vline(90,'--k');
    vline(100,'--k');

    axis xy;
    
    if sb == 18
        xlabel('Frequency (Hz): averaged between 100 and 300ms');
    end
    
    if  sb == 8
        ylabel('Trials');
    end
    
    caxis([0 5]) % [mean_data-std_data mean_data+std_data]);
    xlim(freq_choose)
    
    set(gca,'YDir','normal')
    colormap(brewermap(256, '*RdYlBu'));
    
    title(suj)
    
    clearvars -except sb suj_list
    
end

%     h = colorbar();
%     lm_1            = find(round(freq.freq,1) == round(60,1));
%     lm_2            = find(round(freq.freq,1) == round(100,1));
%     data            = squeeze(mean(data(:,lm_1:lm_2,:),2));
%     data            = mean(data,1);
%     find_max        = round(freq.time(find(data == max(data))),3);
%     plot_y_axis       = freq.time;
%
%     big_max(sb,1)       = find_max;
%     big_data(sb,:)      = data;