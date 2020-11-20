clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_list      = suj_group{3};

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    for cond_main           = {'DIS','fDIS'}
        
        cond_sub            = {''};
        cond_ix_cue         = {0:2};
        cond_ix_dis         = {1:2};
        cond_ix_tar         = {1:4};
        
        fname_in            = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.' cond_main{:} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        clear avg ni;
        
        for xcon = 1:length(cond_sub)
            
            cfg                     = [];
            cfg.trials              = h_chooseTrial(data_elan,cond_ix_cue{xcon},cond_ix_dis{xcon},cond_ix_tar{xcon});
            data_slct               = ft_selectdata(cfg,data_elan);
            
            data_slct               = h_removeEvoked(data_slct);
            
            cfg                     = [];
            cfg.output              = 'pow';
            
            cfg.method              = 'wavelet';
            cfg.output              = 'pow';
            t_step                  = 0.01;
            cfg.toi                 = -1:t_step:1;
            cfg.foi                 = 40:120;
            cfg.width               = 7; % (default = 7)
            cfg.gwidth              = 3; % (default = 3)
            
            cfg.keeptrials          = 'no';
            
            freq                    = ft_freqanalysis(cfg, data_slct);
            
            freq                    = rmfield(freq,'cfg');
            
            name_ext_tfr            = [cfg.method upper(cfg.output)];
            
            name_ext_time           = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000) '.' num2str(t_step*1000) 'Mstep'];
            name_ext_freq           = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];
            
            if strcmp(cfg.keeptrials,'yes')
                name_ext_trials = 'KeepTrials';
            else
                name_ext_trials = 'AvgTrials';
            end
            
            extra_name              = 'MinEvoked';
            
            fname_out               = ['/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/data/dis_sensor_data/' suj '.' cond_sub{xcon} cond_main{:} '.' name_ext_tfr '.' name_ext_freq '.' name_ext_time '.' name_ext_trials '.' extra_name '.mat'];
            
            fprintf('Saving %s\n',fname_out);
            
            save(fname_out,'freq','-v7.3');
            
            clear freq data_slct
            
        end
    end
end