clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

[~,suj_group{1},~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list                        = suj_group{1}(2:22);

ix                              = 0;

for nchan = 1:7
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for ncue = 1:length(list_ix_cue)
            
            ext_file            = 'eeg.nonfilt.waveletPOW.10t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
            suj                 = suj_list{sb};
            dir_data            = '../data/dis_rep4rev/';
            fname_in            = [dir_data suj '.' list_ix_cue{ncue} 'DIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq_activation                 = freq; clear freq ;
            
            fname_in                        = [dir_data suj '.' list_ix_cue{ncue} 'fDIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq_baseline                   = freq; clear freq ;
            
            freq_to_plot                    = freq_activation;
            freq_to_plot.powspctrm          = (freq_to_plot.powspctrm - freq_baseline.powspctrm);
            
            freq_to_plot.powspctrm          = freq_to_plot.powspctrm/10e4;
            
            ix                              = ix + 1;
            
            subplot(7,21,ix);
            
            zlimit                          = 0.1;
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.xlim                        = [-0.1 0.35];
            cfg.comment                     = 'no';
            cfg.colorbar                    = 'no';
            cfg.zlim                        = [-zlimit zlimit];
            ft_singleplotTFR(cfg,freq_to_plot);
            vline(0,'k--')
            
            title([suj '.' freq_to_plot.label{nchan}]);
            
        end
    end
end