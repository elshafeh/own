
clear ; clc ;dleiftrip_addpath;

for ext_cnd = {'CnD'};
    
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
        
        data_f      = ft_appenddata([],data{:}); clear data ;
        data_slct   = data_f; clear data_f
        
        avg         = ft_timelockanalysis([],data_slct);
        
        for n = 1:length(data_slct.trial)
            data_slct.trial{n} = data_slct.trial{n}-avg.avg;
        end
        
        clear avg;
        
        %per cue
        for cnd = 1:4

            cfg                 = [];
            cfg.toi             = -2:0.05:2;
            cfg.method          = 'wavelet';
            cfg.output          = 'pow';
            cfg.foi             =  14:2:50;
            cfg.width           =  7 ;
            cfg.gwidth          =  4 ;
            cfg.keeptrials      = 'no';
        
        if cnd < 3
            cfg.trials      = h_chooseTrial(data_slct,cnd,0,1:4);
        else
            cfg.trials      = h_chooseTrial(data_slct,0,0,[cnd-2 cnd]);
        end
        
        freq                = ft_freqanalysis(cfg,data_slct);
        
        if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
        if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
        
        lst_cnd             = {'L','R','NL','NR'};
        
        ext1        = [suj '.' lst_cnd{cnd} ext_cnd{:} '.'  ext_trials '.' ext_method '.'];
        ext2        = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz.m'];ext3        = [num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        fname_out   = [ext1 ext2 ext3];
        
        fprintf('\n Saving %50s \n',fname_out);
        freq = rmfield(freq,'cfg');save(['../data/tfr/' fname_out '.MinusEvoked.mat'],'freq','-v7.3');
        clear freq fname_out ext1 ext2 ext3 cfg
        
        end
        
        clear data_slct ;
        
    end
end