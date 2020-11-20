clear ; clc ; close all ; dleiftrip_addpath;

cnd = {'RCnD','LCnD','NCnD','VCnD','CnD'};

suj_list = [1:4 8:17];

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))];
    
    for c = 1:length(cnd)
        
        for b = 1:3
            
            fname_in = dir(['../data/' suj '/pe/' suj '.pt' num2str(b) '.' cnd{c} '.RevFinalBaselineTimeCourse.mat']);
            fprintf('\nLoading %50s \n',fname_in.name);
            load(['../data/' suj '/pe/' fname_in.name])
            
            tmp{b} = virtsens ; clear virtsens ;
            
        end
        
        clear b
        
        data    = ft_appenddata([],tmp{:});
        avg     = ft_timelockanalysis([],data);
        
        data_subt = data ; 
        
        for ntr = 1:length(data.trial)
            data_subt.trial{ntr} = data_subt.trial{ntr} - avg.avg;
        end
        
        clear tmp
        
        cfg                 = [];
        cfg.method          = 'wavelet';
        cfg.output          = 'pow';
        cfg.width           =  7 ;
        cfg.gwidth          =  4 ;
        cfg.toi             = -3:0.05:3;
        cfg.foi             =  1:1:20;
        
        allsuj{a,c}         = ft_freqanalysis(cfg,data_subt);
        
        clear data cfg data_subt
        
    end
    
end

clearvars -except allsuj

save('../data/yctot/SayWhatFinalExtWavMinusEvoked.mat');