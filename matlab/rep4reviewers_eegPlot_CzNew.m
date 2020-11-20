clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

[~,suj_group{1},~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list                        = suj_group{1}(2:22);

ix                              = 0;
ax_data                     = [];

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    cnd_dis             = {'DIS','fDIS'};
    ext_file            = 'eeg.nonfilt.waveletPOW.10t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
    
    for ndis = 1:2
        dir_data        = '../data/dis_rep4rev/';
        fname_in        = [dir_data suj '.' cnd_dis{ndis} '.' ext_file];
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        tmp{ndis}       = freq.powspctrm;
        ax_chan         = freq.label;
        ax_time         = freq.time;
        ax_freq         = freq.freq;
        
        clear freq;
        
    end
    
    pow             = tmp{1} - tmp{2}; clear tmp
    ax_data         = cat(4,ax_data,pow);
    
end

clearvars -except ax_*;

freq.powspctrm      = nanmean(ax_data,4);
freq.freq           = ax_freq;
freq.time           = ax_time;
freq.label          = ax_chan;
freq.dimord         = 'chan_freq_time';

for nchan = 1:7
    
    zlimit                                      = 2e07;
    
    cfg                                         = [];
    cfg.channel                                 = nchan;
    cfg.xlim                                    = [0 0.35];
    cfg.comment                                 = 'no';
    cfg.colorbar                                = 'yes';
    %     cfg.zlim                                    = [-zlimit zlimit];
    
    subplot(4,2,nchan)
    ft_singleplotTFR(cfg,freq);
    vline(0,'k--')
    
end