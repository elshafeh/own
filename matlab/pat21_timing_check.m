clear ; clc ; dleiftrip_addpath ;

% hp (2) filter and then offset

for cnd = 2
    
    cfg                     = [];
    cfg.dataset             = ['/Users/heshamelshafei/Desktop/test/lyon_CAT_20170303_0' num2str(cnd) '.ds'];
    cfg.channel             = {'UPPT001','UADC001','UADC002'};
    cfg.demean              = 'yes';
    data                    = ft_preprocessing(cfg);
    
    cfg                     = [];
    cfg.hpfilter            = 'yes';
    cfg.hpfiltord           = 2;
    cfg.hpfreq              = 2;
    data_orig               = ft_preprocessing(cfg,data);
    
    cfg                     = [];
    cfg.trialdef.eventtype  = 'UPPT001';
    cfg.trials              = 'all';
    cfg.dataset             = ['/Users/heshamelshafei/Desktop/test/lyon_CAT_20170303_0' num2str(cnd) '.ds'];
    cfg.trialdef.eventvalue = [1 2 3 4  101 103 202 204]; % [61 62 63 64] [51 52 53] [1 2 3 4  101 103 202 204]
    cfg.trialdef.prestim    = 0.5;
    cfg.trialdef.poststim   = 3;
    tcfg                     = ft_definetrial(cfg);
    
    cfg                     = [];
    cfg.trl                 = tcfg.trl;
    data                    = ft_redefinetrial(cfg,data_orig);
    
    avg = ft_timelockanalysis([],data);
    
    figure;
    cfg         = [];
    cfg.xlim    = [-0.05 0.5];
    cfg.channel = 3;
    ft_singleplotER(cfg,avg);
    
    cfg                     = [];
    cfg.trialdef.eventtype  = 'UPPT001';
    cfg.trials              = 'all';
    cfg.dataset             = ['/Users/heshamelshafei/Desktop/test/lyon_CAT_20170303_0' num2str(cnd) '.ds'];
    cfg.trialdef.eventvalue = [61 62 63 64] ;
    cfg.trialdef.prestim    = 0.5;
    cfg.trialdef.poststim   = 3;
    tcfg                    = ft_definetrial(cfg);
    
    cfg                     = [];
    cfg.trl                 = tcfg.trl;
    data                    = ft_redefinetrial(cfg,data_orig);
    
    avg = ft_timelockanalysis([],data);
    
    figure;
    cfg         = [];
    cfg.xlim    = [-0.05 0.5];
    cfg.channel = 2;
    ft_singleplotER(cfg,avg);
    
    cfg                     = [];
    cfg.trialdef.eventtype  = 'UPPT001';
    cfg.trials              = 'all';
    cfg.dataset             = ['/Users/heshamelshafei/Desktop/test/lyon_CAT_20170303_0' num2str(cnd) '.ds'];
    cfg.trialdef.eventvalue = [51 52 53] ;
    cfg.trialdef.prestim    = 0.5;
    cfg.trialdef.poststim   = 3;
    tcfg                     = ft_definetrial(cfg);
    
    cfg                     = [];
    cfg.trl                 = tcfg.trl;
    data                    = ft_redefinetrial(cfg,data_orig);
    
    avg = ft_timelockanalysis([],data);
    
    figure;
    cfg         = [];
    cfg.xlim    = [-0.05 0.5];
    cfg.channel = 2;
    ft_singleplotER(cfg,avg);
end