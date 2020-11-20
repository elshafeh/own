clear; clc ; dleiftrip_addpath ;

cnd_list = {'CnD'};

for cnd = 1:length(cnd_list)
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        suj = ['yc' num2str(suj_list(sb))];
        
        ext_essai   = 'NewFronalAndAuditoryIndex';
        
        fname_in = [suj '.' cnd_list{cnd} '.' ext_essai];
        fprintf('\nLoading %50s \n\n',fname_in);
        load(['../data/pe/' fname_in '.mat'])
        
        cfg                 = [];
        cfg.trials          = 'all';
        data_slct           = ft_selectdata(cfg,virtsens);
        avg                 = ft_timelockanalysis([],virtsens) ;
        
        for n = 1:length(data_slct.trial)
            data_slct.trial{n} = data_slct.trial{n}-avg.avg;
        end
        
        clear avg ;
        
        cfg                 = [];
        cfg.toi             = -2:0.01:2;
        cfg.method          = 'wavelet';
        cfg.output          = 'pow';
        cfg.foi             =  40:1:120;
        cfg.width           =  7;
        cfg.gwidth          =  4;
        cfg.keeptrials      = 'no';
        freq                = ft_freqanalysis(cfg,data_slct);
        freq                = rmfield(freq,'cfg');
        
        if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
        if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
        
        ext_time            = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        ext_freq            = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];
        
        ext_cnd             = [cnd_list{cnd}] ;
        fname_out           = ['../data/tfr/' suj '.' ext_cnd '.' ext_essai '.' ext_trials '.' ext_method '.MinEvoked.' ext_freq '.' ext_time '.mat'];
        
        fprintf('\nSaving %50s \n\n',fname_out);
        save(fname_out,'freq','-v7.3');
        
        clear freq
        
        clear virtsens;clc;
        
    end
end