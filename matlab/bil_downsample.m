clear ;

suj_list                                = {'pil01','pil02','pil03','pil05'};

for ns = 1:length(suj_list)
    
    subjectName                         = suj_list{ns};
    
    dir_data                            = ['../data/' subjectName '/preproc/'];
    
    fname                               = [dir_data subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    fname                               = [dir_data subjectName '_allTrialInfo.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    cfg                                 = [];
    cfg.latency                         = [-1 1];
    dataPostICA_clean                   = ft_selectdata(cfg,dataPostICA_clean);
    
    cfg                                 = [];
    cfg.resamplefs                      = 100;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'yes';
    data                                = ft_resampledata(cfg, dataPostICA_clean);
    data                                = rmfield(data,'cfg');
    
    ext_lock                            = '_firstcueLock_';
    
    fname                               = [dir_data subjectName ext_lock 'dwnsample100Hz.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'data','-v7.3');toc;
    
    index                               = data.trialinfo;
    fname                               = [dir_data subjectName ext_lock 'trialinfo.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'index');toc;
    
end