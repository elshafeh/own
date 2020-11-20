clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))];
    
    fname_in    = ['../data/paper_data/' suj '.CnD.all.wav.1t30Hz.m3000p3000.mat'];
    
    load(fname_in);
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg,freq);
    
    cfg                 = [];
    cfg.frequency       = [7 30];
    freq                = ft_selectdata(cfg,freq);
    
    allsuj_data{sb,1}   = freq;
    
end

clearvars -except allsuj_data ;

grandAverage = ft_freqgrandaverage([],allsuj_data{:,1});

cfg             = [];
cfg.layout      = 'CTF275.lay';
cfg.xlim        = [-0.2 1.2];
cfg.zlim        = [-0.3 0.3];
ft_topoplotTFR(cfg,grandAverage);

cfg             = [];
cfg.layout      = 'CTF275.lay';
cfg.xlim        = [-0.2 1.2];
cfg.zlim        = [-0.25 0.25];
cfg.channel = {'MLO11', 'MLO21', 'MLO22', 'MLO31', 'MLO32', 'MLO41', 'MLO42', ...
    'MLO51', 'MRO11', 'MRO21', 'MRO22', 'MRO23', 'MRO31', 'MRO32', 'MRO41', ...
    'MRO42', 'MRO43', 'MRO51', 'MRO52'};
subplot(2,1,1)
ft_singleplotTFR(cfg,grandAverage);
title('Alpha Power Averaged Over Occipital Cortex');
vline(0,'--k')

cfg             = [];
cfg.latency     = [0.6 1];
cfg.avgovertime = 'yes';
cfg.channel     = {'MLO11', 'MLO21', 'MLO22', 'MLO31', 'MLO32', 'MLO41', 'MLO42', ...
    'MLO51', 'MRO11', 'MRO21', 'MRO22', 'MRO23', 'MRO31', 'MRO32', 'MRO41', ...
    'MRO42', 'MRO43', 'MRO51', 'MRO52'};
cfg.avgoverchan = 'yes';
dataSlct        = ft_selectdata(cfg,grandAverage);
subplot(2,1,2)
plot(dataSlct.freq,squeeze(dataSlct.powspctrm));
xlim([dataSlct.freq(1) dataSlct.freq(end)])
ylim([-0.2 0.2]);
vline(14,'-k')
title('Alpha Power Averaged Over Occipital Cortex Over Time');
saveas(gcf,'../images/prep21_cluster_limits.svg') ; 