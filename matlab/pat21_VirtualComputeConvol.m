clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    cond_list = {'RCnD','LCnD','NCnD','VCnD','CnD'} ;
    
    for cnd = 1:length(cond_list)
        
        for prt = 1:3
            
            ext = 'Paper';
            
            fname_in = dir(['../data/' suj '/pe/' suj '.pt' num2str(prt) '.' cond_list{cnd} '.' ext '.TimeCourse.mat']);
            fprintf('\nLoading %50s \n',fname_in.name);
            load(['../data/' suj '/pe/' fname_in.name])
            
            tmp{prt} = virtsens ; clear virtsens ;
            
        end
        
        data = ft_appenddata([],tmp{:});
        
        clear tmp
        
        cfg = [];
        cfg.method          = 'mtmconvol';
        cfg.taper           = 'hanning' ;
        cfg.foi             = 5:18;
        cfg.t_ftimwin       = 5./cfg.foi; % 5 cycles
        cfg.toi             = -3:0.05:3 ;
        
        allsuj{sb,cnd}      = ft_freqanalysis(cfg,data);
        
        
        template.time   = allsuj{sb,cnd}.time ;
        template.freq   = allsuj{sb,cnd}.freq ;
        template.label  = allsuj{sb,cnd}.label ;
        
        allsuj{sb,cnd}  = allsuj{sb,cnd}.powspctrm;
        
        
        clear data
        
    end
    
end

clearvars -except allsuj ext template

save(['../data/yctot/' ext 'ExtConvol.mat'],'-v7.3');