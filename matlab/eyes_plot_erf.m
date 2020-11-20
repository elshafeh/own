clear;

suj_list                                = dir('F:\eyes\*_stimLock_ICAlean_finalrej.mat');

for nsuj = 1:length(suj_list)
    
    sujname                             = suj_list(1).name(1:6);    
    fname                               = [suj_list(nsuj).folder filesep suj_list(nsuj).name];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                                 = [];
    cfg.demean                          = 'yes';
    cfg.baselinewindow                  = [-0.1 0];
    cfg.lpfilter                        = 'yes';
    cfg.lpfreq                          = 20;
    
    data                                = ft_preprocessing(cfg,dataPostICA_clean);  
    avg                                 = ft_timelockanalysis([], data);
    
    cfg                                 = [];
    cfg.feedback                        = 'yes';
    cfg.method                          = 'template';
    cfg.neighbours                      = ft_prepare_neighbours(cfg, avg); close all;
    
    cfg.planarmethod                    = 'sincos';
    avg_planar                          = ft_megplanar(cfg, avg);
    avg_comb                            = ft_combineplanar([],avg_planar);
    
    alldata{nsuj,1}                     = avg_comb;
    alldata{nsuj,2}                     = avg; keep alldata suj_list nsuj
    
end