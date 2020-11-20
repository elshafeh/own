clear ; clc ;

suj_list = [1:4 8:17];dleiftrip_addpath;

for sb = 2:length(suj_list)
    
    condtn = {'CnD'};
    
    for cnd = 1:length(condtn)
        
        for pt =1:3
            
            suj = ['yc' num2str(suj_list(sb))] ;
            
            fname_in = [suj '.pt' num2str(pt) '.' condtn{cnd}];
            fprintf('\nLoading %50s\n',fname_in);
            load(['../data/' suj '/elan/' fname_in '.mat'])
            
            cfg                 = [];
            cfg.method          = 'template';
            cfg.template        = 'CTF275_neighb.mat';
            neighbours          = ft_prepare_neighbours(cfg, data_elan);
            
            cfg                 = [];
            cfg.method          = 'template';
            cfg.neighbours      = neighbours;
            data_f              = ft_megplanar(cfg, data_elan);
            
            
            cfg                 = [];
            cfg.toi             = -3:0.05:3;
            cfg.method          = 'wavelet';
            cfg.output          = 'pow';
            cfg.foi             =  5:1:18;
            cfg.keeptrials      = 'yes';
            cfg.width           =  7 ;
            cfg.gwidth          =  4 ;
            
            tmp                 = ft_freqanalysis(cfg,data_f);
            tmp_carr{pt}        = ft_combineplanar([],tmp);
            
            clear data_f
            
            clear tmp
            
        end
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';
        freq            = ft_appendfreq(cfg,tmp_carr{:});
        
        cfg.toi             = -3:0.05:3;
        cfg.foi             =  5:1:18;
        
        clear tmp_carr
        
        fname_out = [suj '.' condtn{cnd} '.KTPlanar.wav.' num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz.m' num2str(abs(cfg.toi(1))) 'p' num2str(cfg.toi(end))];
        
        fprintf('\n Saving %50s \n',fname_out);
        
        save(['../data/' suj '/tfr/' fname_out '.mat'],'freq','-v7.3');
        
        clear freq
        
    end
    
end