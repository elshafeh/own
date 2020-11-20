clear ; clc ;dleiftrip_addpath;

for ext_cnd = {'CnD','nDT','DIS','fDIS'};
    
    for sb = 1:14
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(sb))] ;
        
        for prt = 1:3
            fname_in = [suj '.pt' num2str(prt) '.' ext_cnd{:}];
            fprintf('\nLoading %50s\n',fname_in);
            load(['../data/elan/' fname_in '.mat'])
            data{prt} = data_elan ;
            clear data_elan virtsens
        end
        
        data_f              = ft_appenddata([],data{:}); clear data ;
        avg                 = ft_timelockanalysis([],data_f); clear data_f
        
        cfg                 = [];
        cfg.toi             = -0.3:0.01:1.2;
        cfg.method          = 'wavelet';
        cfg.output          = 'pow';
        cfg.foi             =  40:5:150;
        cfg.width           =  7;
        cfg.gwidth          =  4;
        cfg.keeptrials      = 'no';
        freq                = ft_freqanalysis(cfg,avg);
        
        if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
        if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
        
        ext1        = [suj '.' ext_cnd{:} '.'  ext_trials '.' ext_method '.'];
        ext2        = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz.m'];ext3        = [num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        fname_out   = [ext1 ext2 ext3];
        
        fprintf('\n Saving %50s \n',fname_out);
        freq = rmfield(freq,'cfg');save(['../data/tfr/' fname_out '.Evoked.mat'],'freq','-v7.3');
        clear freq fname_out ext1 ext2 ext3 data_slct cfg
        
    end
end