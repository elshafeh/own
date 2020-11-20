clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for prt = 1:3
        
        ext = 'postConn';
        
        fname_in = dir(['../data/' suj '/pe/' suj '.pt' num2str(prt) '.CnD.' ext '.TimeCourse.mat']);
        fprintf('\nLoading %50s \n',fname_in.name);
        load(['../data/' suj '/pe/' fname_in.name])
        
        tmp{prt} = virtsens ; clear virtsens ;
        
    end
    
    data = ft_appenddata([],tmp{:});
    
    cfg                 = [];
    cfg.method          = 'wavelet';
    cfg.output          = 'pow';
    cfg.width           =  7 ;
    cfg.gwidth          =  4 ;
    cfg.toi             = -3:0.05:3;
    cfg.foi             =  1:1:20;
    cfg.trials          = trl_list;
    %         cfg.keeptrials      = 'yes';
    
    allsuj{sb,cnd}         = ft_freqanalysis(cfg,data);
    
end