clear ; clc ;dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    ext_cnd = {'DIS','fDIS'};
    
    for cnd = 1:length(ext_cnd)
        
        for prt = 1:3
            
            suj = ['yc' num2str(suj_list(sb))] ;
            
            fname_in = [suj '.pt' num2str(prt) '.' ext_cnd{cnd}];
            
            fprintf('\nLoading %50s\n',fname_in);
            load(['../data/elan/' fname_in '.mat'])
            
            data{prt} = data_elan ;
            
            clear data_elan virtsens
            
        end
        
        data_f = ft_appenddata([],data{:});
        
        clear data
        
        cfg                 = [];
        cfg.toi             = -1.5:0.05:1.5;
        cfg.method          = 'wavelet';
        cfg.output          = 'pow';
        cfg.foi             =  1:1:100;
        cfg.width           =  7 ;
        cfg.gwidth          =  4 ;
        cfg.keeptrials      = 'no' ;
        
        list_cnd_cue = 'LR' ;
        
        for cnd_cue = 1:2
            
            cfg.trials = h_chooseTrial(data_f,cnd_cue,1:3,1:4);
            freq             = ft_freqanalysis(cfg,data_f);
            
            if strcmp(cfg.keeptrials,'yes');ext_trials = 'KeepTrial';else ext_trials = 'all';end
            if strcmp(cfg.method,'wavelet'); ext_method = 'wav';else ext_method = 'conv';end;
            
            fname_out = [suj '.' list_cnd_cue(cnd_cue) ext_cnd{cnd} '.' ext_trials '.' ext_method '.' ...
                num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz.m' ...
                num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
            
            fprintf('\n Saving %50s \n',fname_out); freq = rmfield(freq,'cfg'); save(['../data/tfr/' fname_out '.mat'],'freq','-v7.3');
            
            clear freq fname_out
            
        end
        
        clear data_f
    end
end


% ---- convol

%         cfg = [];
%         cfg.method            = 'mtmconvol';
%         cfg.taper             = 'hanning' ;
%         cfg.foi               = 5:18;
%         cfg.t_ftimwin         = 5./cfg.foi; % 5 cycles
%         cfg.toi               = -4:0.05:4 ;
%         cfg.keeptrials       = 'yes';

% ---- wavelet