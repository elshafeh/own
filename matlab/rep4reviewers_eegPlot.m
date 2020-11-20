clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

[~,suj_group{1},~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list                        = suj_group{1}(2:22);


for sb = 1:length(suj_list)
    
    %         ext_file            = 'eeg.nonfilt.waveletPOW.10t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
        ext_file            = 'eeg.regress.waveletPOW.10t40Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
        suj                 = suj_list{sb};
        dir_data            = '../data/dis_rep4rev/';
        fname_in            = [dir_data suj '.DIS.' ext_file];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        allsuj_activation{sb}   = freq; clear freq ;
        
        fname_in            = [dir_data suj '.fDIS.' ext_file];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        allsuj_baselineRep{sb}             = freq; clear freq ;
        
        allsuj_correction{sb}              = allsuj_activation{sb};
        pow                                = allsuj_activation{sb}.powspctrm - allsuj_baselineRep{sb}.powspctrm;
        allsuj_correction{sb}.powspctrm    = pow ; clear pow ;
end

clearvars -except allsuj_*;

% grand_average_act                   = ft_freqgrandaverage([],allsuj_activation{:,1});
% grand_average_bsl                   = ft_freqgrandaverage([],allsuj_baselineRep{:,1});
grand_average_cor                   = ft_freqgrandaverage([],allsuj_correction{:});

% grand_average_cor                   = grand_average_act;
% grand_average_cor.powspctrm         = (grand_average_act.powspctrm - grand_average_bsl.powspctrm);

for nchan = 1:length(grand_average_cor.label)
    
    subplot(4,2,nchan)
    
    %     if nchan == 2
    %         zlimit                                      = 2e06;
    %     else
    %         zlimit                                      = 2e07;
    %     end
    
    zlimit                                      = 9e06;
    
    cfg                                         = [];
    cfg.channel                                 = nchan;
    cfg.xlim                                    = [-0.1 0.35];
    %     cfg.ylim                                    = [30 110];
    cfg.comment                                 = 'no';
    cfg.colorbar                                = 'yes';
    cfg.zlim                                    = [-zlimit zlimit];
    
    ft_singleplotTFR(cfg,grand_average_cor);
    vline(0,'k--')
    
end

% dir_out = '~/GoogleDrive/NeuroProj/Publications/Papers/distractor2018/cerebcortex2018/_rep_for_reviews/';
%
% saveas(gcf,[dir_out 'tf_eeg_plot.svg']);
%
% close all;