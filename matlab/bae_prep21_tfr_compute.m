clear ; clc ;

for ext_cnd = {'CnD'};
    
    for sb = 1:14
        
        suj_list                = [1:4 8:17];
        suj                     = ['yc' num2str(suj_list(sb))] ;

        for prt = 1:3
            
            fname_in            = [suj '.pt' num2str(prt) '.' ext_cnd{:}];
            
            fprintf('\nLoading %50s\n',fname_in);
            load(['/media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/all_data/' fname_in '.mat'])
            
            data{prt}           = data_elan ;
            
            clear data_elan virtsens
            
        end
        
        data_f              = ft_appenddata([],data{:}); clear data
                
        cfg                 = [];
        cfg.toi             = -3:0.05:3;
        cfg.method          = 'wavelet';
        cfg.output          = 'pow';
        cfg.foi             =  1:1:30;
        cfg.width           =  7 ;
        cfg.gwidth          =  4 ;
        cfg.keeptrials      = 'no';
        
        freq                = ft_freqanalysis(cfg,data_f);
        
        if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
        if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
        
        new_cnd             = [ext_cnd{:}];
        
        ext1                = [suj '.' new_cnd '.' ext_trials '.' ext_method '.'];
        ext2                = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz.m'];
        ext3                = [num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        fname_out           = [ext1 ext2 ext3];
        
        fprintf('\n Saving %50s \n',fname_out);
        freq                = rmfield(freq,'cfg');
        save(['/dycog/Aurelie/DATA/MEG/PAT_MEG21/pat.field/data/' fname_out '.mat'],'freq','-v7.3');
        
        clear freq fname_out ext1 ext2 ext3
        
        clear data_f
        
    end
end