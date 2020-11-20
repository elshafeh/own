clear ;

list_files = dir('../data/sub*/preprocessed/*secondreject*');

for nf = 1:length(list_files)
    
    nme_prts                            = strsplit(list_files(nf).name,'_');
    suj                                 = nme_prts{1};
    modality                            = nme_prts{end}(1:3);
    
    fname                               = [list_files(nf).folder '/' list_files(nf).name];
    fprintf('Loading %s \n',fname);
    load(fname);
    
    cfg                                 = [];
    cfg.resamplefs                      = 100;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'yes';
    data                                = ft_resampledata(cfg, secondreject_postica);
    
    cfg                                 = [];
    cfg.latency                         = [-1 1];
    data                                = ft_selectdata(cfg,data);
    
    data                                = rmfield(data,'cfg');
    
    fname                               = ['../dec_data/' suj '_' modality '_dwnsample100Hz.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'data','-v7.3');toc;
    
    index                               = data.trialinfo;
    fname                               = ['../dec_data/' suj '_' modality '_trialinfo.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'index');toc;
    
end