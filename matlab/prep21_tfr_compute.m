clear ; clc ;

for ext_cnd = {'CnD'};
    
    for sb = 1:14
        
        suj_list                = [1:4 8:17];
        suj                     = ['yc' num2str(suj_list(sb))] ;
        
        for prt = 1:3
            
            fname_in            = [suj '.pt' num2str(prt) '.' ext_cnd{:}];
            
            fprintf('\nLoading %50s\n',fname_in);
            load(['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' fname_in '.mat'])
            
            data{prt}           = data_elan ;
            
            clear data_elan virtsens
            
        end
        
        data_f                  = ft_appenddata([],data{:}); clear data
        
        list_foi                = {10:2:60,1:10};
        list_toi                = {-1:0.01:2,-3:0.05:3};
        
        for ncalcul = 1:2
            
            cfg                 = [];
            cfg.method          = 'wavelet';
            cfg.output          = 'pow';
            
            cfg.toi             = list_toi{ncalcul};    %-1:0.01:2;
            cfg.foi             = list_foi{ncalcul};   % 10:1:60;
            
            cfg.width           =  7 ;
            cfg.gwidth          =  4 ;
            
            cfg.keeptrials      = 'yes';
            
            if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
            if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
            
            remove_evoked       = 'yes';
            
            if strcmp(remove_evoked,'yes')
                ext_trials      = [ext_trials 'MinEvoked'];
                new_data_f      = h_removeEvoked(data_f);
            else
                ext_trials = [ext_trials 'eEvoked'];
                new_data_f = data_f;
            end
            
            
            freq                = ft_freqanalysis(cfg,new_data_f);
            
            new_cnd             = [ext_cnd{:}];
            
            ext1                = [suj '.' new_cnd '.' ext_trials '.' ext_method '.'];
            
            ext2                = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz.m'];
            
            ext3                = [num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
            
            fname_out           = [ext1 ext2 ext3];
            
            fprintf('\n Saving %50s \n',fname_out);
            
            freq                = rmfield(freq,'cfg');
            
            save(['/Volumes/Pat22Backup/thetabetadata/' fname_out '.mat'],'freq','-v7.3');
            
        end
        
        clearvars -except sb ext_cnd suj_list
        
    end
end