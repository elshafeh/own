clear ; clc ;dleiftrip_addpath;

suj_list = 14:17;

for sb = 1:length(suj_list)
    
    for cndcnd = 1:2
        
        ext_cnd         = {{'DIS1','DIS2','DIS3'},{'fDIS1','fDIS2','fDIS3'}};
        mega_ext_cnd    = {'DIS','fDIS'};
        
        for cnd = 1:3
            
            for prt =1:3
                
                suj = ['yc' num2str(suj_list(sb))] ;
                
                fname_in = [suj '.pt' num2str(prt) '.' ext_cnd{cndcnd}{cnd}];
                
                fprintf('\nLoading %50s\n',fname_in);
                load(['../data/' suj '/elan/' fname_in '.mat'])
                
                data{cnd,prt} = data_elan ;
                
                clear data_elan virtsens
                
            end
            
        end
        
        data_f = ft_appenddata([],data{:,:});
        
        clear data
        
        % ---- wavelet
        
        cfg                 = [];
        cfg.toi             = -3:0.05:3;
        cfg.method          = 'wavelet';
        cfg.output          = 'pow';
        cfg.foi             =  1:1:100;
        cfg.width           =  7 ;
        cfg.gwidth          =  4 ;
        cfg.keeptrials      = 'no' ;
        freq                = ft_freqanalysis(cfg,data_f);
        
        ext_trials = 'all';
        ext_method = 'wav';
        
        fname_out = [suj '.' mega_ext_cnd{cndcnd} '.' ext_trials '.' ext_method '.' ...
            num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz.m' ...
            num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        
        fprintf('\n Saving %50s \n',fname_out);
        
        freq.cfg = [];
        
        save(['../data/' suj '/tfr/' fname_out '.mat'],'freq','-v7.3');
        
        clear freq data_f
        
    end
    
end
