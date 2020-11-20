clear ;

for ns = 1:51
    
    fname                               = ['../data/prepro/vis/data' num2str(ns) '.mat'; ];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    data                                = rmfield(data,'grad');
    data                                = rmfield(data,'cfg');
    
    cfg                                 = [];
    cfg.latency                         = [-0.5 1];
    data                                = ft_selectdata(cfg,data);
    
    cfg                                 = [];
    cfg.resamplefs                      = 100;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'yes';
    data                                = ft_resampledata(cfg, data);
    data                                = rmfield(data,'cfg');
    
    index                               = data.trialinfo;
    
    index(find(index == 15))            = 0;
    index(find(index == 240))           = 1;
    
    fname_out                           = ['../data/decode/grating/data' num2str(ns) '.grating.dwsmple.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'data','-v7.3');toc;
    
    fname_out                           = ['../data/decode/grating/data' num2str(ns) '.grating.dwsmple.trialinfo.mat'];
    fprintf('Saving %s\n',fname_out);
    tic;save(fname_out,'index');toc;
    
end