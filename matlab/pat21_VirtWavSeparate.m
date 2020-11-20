clear; clc ; dleiftrip_addpath ;

cnd_list = {'DIS','fDIS'};

for cnd = 1:length(cnd_list)
    for sb = 1:14
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(sb))];
        ext_essai   = 'RamaBigCov';
        
        fname_in = [suj '.' cnd_list{cnd} '.' ext_essai];
        fprintf('\nLoading %50s \n',fname_in);
        load(['../data/pe/' fname_in '.mat'])
        
        %         virtsens    = h_SomaPrepare(virtsens);
        
        cfg         = [];
        cfg.channel = [10 11 88 89 90 91 99];
        virtsens    = ft_selectdata(cfg,virtsens);
        
        ext_essai   = [cnd_list{cnd} '.' ext_essai '.AuditoryTPJ'];
        
        for cnd_cue = 1:3
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(virtsens,cnd_cue-1,1:3,1:4);
            
            %             if cnd_cue < 4
            %                 cfg.trials = h_chooseTrial(virtsens,cnd_cue-1,0,1:4);
            %             else
            %                 cfg.trials = h_chooseTrial(virtsens,cnd_cue-3,0,[cnd_cue-3 cnd_cue-1]);
            %             end
            
            cfg.method                  = 'wavelet';
            cfg.output                  = 'pow';
            cfg.keeptrials              = 'no';
            cfg.width                   =  7 ;
            cfg.gwidth                  =  4 ;
            cfg.toi                     = -3:0.01:3;
            cfg.foi                     = [4:1:20 22:2:140];
            freq                        = ft_freqanalysis(cfg,virtsens);
            freq                        = rmfield(freq,'cfg');
            
            if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
            if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
            
            lst_cue                     = {'N','L','R'};
            
            ext_time                    = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
            ext_freq                    = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];
            ext_cnd                     = [lst_cue{cnd_cue} cnd_list{cnd}] ;
            
            fname_out = ['../data/tfr/' suj '.' lst_cue{cnd_cue} ext_essai '.' ext_trials '.' ext_method upper(cfg.output) '.' ext_freq '.' ext_time '.mat'];
            
            %             fname_out = ['../data/tfr/' suj '.SomaAuditoryVisualAlpaBetaGamma.' ext_trials '.' ext_method '.' cfg.output '.mat'];
            
            fprintf('\nSaving %50s \n\n',fname_out);
            save(fname_out,'freq','-v7.3');
            
            clear freq
            
        end
    end
    
    clear virtsens
    
end