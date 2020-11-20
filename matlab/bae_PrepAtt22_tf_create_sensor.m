clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    for cond_main           = {'DIS','fDIS'}
        
        cond_sub            = {'','V','N','1','V1','N1'};
        cond_ix_cue         = {0:2,[1 2],0,0:2,[1 2],0};
        cond_ix_dis         = {1:2,1:2,1:2,1,1,1};
        cond_ix_tar         = {1:4,1:4,1:4,1:4,1:4,1:4};
        
        fname_in            = ['../data/' suj '/field/' suj '.' cond_main{:} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        cfg                 = [];
        cfg.latency         = [-2 2];
        data_elan           = ft_selectdata(cfg,data_elan);
                
        clear avg ni;
        
        for xcon = 1:length(cond_sub)
            
            trial_choose            = h_chooseTrial(data_elan,cond_ix_cue{xcon},cond_ix_dis{xcon},cond_ix_tar{xcon});
            
            cfg                     = [];
            cfg.trials              = trial_choose;
            data_select             = ft_selectdata(cfg,data_elan);
            
            data_select             = h_removeEvoked(data_select); % !!!!

            cfg                     = [];
            cfg.method              = 'wavelet';
            cfg.output              = 'pow';
            
            cfg.foi                 = 10:50;
            t_step                  = 0.01;
            cfg.toi                 = -1:t_step:1;

            cfg.keeptrials          = 'no';
            
            freq                    = ft_freqanalysis(cfg, data_select);
            
            freq                    = rmfield(freq,'cfg');
            freq.check_trialinfo    = data_elan.trialinfo(trial_choose);
            name_ext_tfr            = [cfg.method upper(cfg.output)];
            
            name_ext_time           = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000) '.' num2str(t_step*1000) 'Mstep'];
            
            name_ext_freq           = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];
            
            if strcmp(cfg.keeptrials,'yes')
                name_ext_trials = 'KeepTrials';
            else
                name_ext_trials = 'AvgTrials';
            end
            
            extra_name              = 'MinEvoked';
            
            fname_out               = ['../data/' suj '/field/' suj '.' cond_sub{xcon} cond_main{:} '.' name_ext_tfr '.' name_ext_freq '.' name_ext_time '.' name_ext_trials '.' extra_name '.mat'];
            
            fprintf('Saving %s\n',fname_out);
            
            save(fname_out,'freq','-v7.3');
            
        end
    end
end