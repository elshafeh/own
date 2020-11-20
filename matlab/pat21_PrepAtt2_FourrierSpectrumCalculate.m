clear; clc ; dleiftrip_addpath ;

cnd_list = {'CnD'};

for cnd = 1
    for sb = 1:14
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(sb))];
        ext_essai   = [cnd_list{cnd} '.RamaBigCovSlct'];
        
        fname_in = [suj '.' ext_essai];
        fprintf('\nLoading %50s \n',fname_in);
        load(['../data/all_data/' fname_in '.mat'])
        %
        %         cfg             = [];
        %         cfg.method      = 'wavelet';
        %         cfg.output      = 'fourier';
        %         cfg.toi         = -3:0.05:3;
        %         cfg.foi         = 50:5:140;%[1:1:20 22:2:50];
        %         cfg.keeptrials  = 'yes';
        %         freq            = ft_freqanalysis(cfg, virtsens);
        %         freq            = rmfield(freq,'cfg');
        %
        %         ext_time        = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        %         ext_freq        = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];
        %
        %         if strcmp(cfg.keeptrials,'yes')
        %             ext_trials = 'KeepTrials';
        %         else
        %             ext_trials = 'AvgTrials';
        %         end
        %
        %         fname_out       = ['../data/all_data/' suj '.' ext_essai '.' cfg.method upper(cfg.output) '.' ext_freq '.' ext_time '.' ext_trials '.mat'];
        %         fprintf('\nSaving %50s \n\n',fname_out);
        %         save(fname_out,'freq','-v7.3');
        
        cfg             = [];
        cfg.method      = 'wavelet';
        cfg.output      = 'pow';
        cfg.toi         = -3:0.01:3;
        cfg.foi         = 1:1:140;%[1:1:20 22:2:140];
        cfg.keeptrials  = 'no';
        freq            = ft_freqanalysis(cfg, virtsens);
        freq            = rmfield(freq,'cfg');
        
        ext_time        = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        ext_freq        = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];
        
        if strcmp(cfg.keeptrials,'yes')
            ext_trials = 'KeepTrials';
        else
            ext_trials = 'AvgTrials';
        end
        
        fname_out       = ['../data/all_data/' suj '.' ext_essai '.' cfg.method upper(cfg.output) '.' ext_freq '.' ext_time '.' ext_trials '.mat'];
        fprintf('\nSaving %50s \n\n',fname_out);
        save(fname_out,'freq','-v7.3');
        
        clear freq
        
    end
end