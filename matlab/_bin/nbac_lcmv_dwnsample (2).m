clear;

file_list                           = dir('../data/source/virtual/s*.mat');

for nfile = 1:length(file_list)
    
    fname                           = [file_list(nfile).folder '/' file_list(nfile).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    cfg                             = [];
    cfg.resamplefs                  = 100;
    cfg.detrend                     = 'no';
    cfg.demean                      = 'no';
    data                            = ft_resampledata(cfg, data);
    data                            = rmfield(data,'cfg');
    
    fprintf('\nsaving %s\n',fname);
    save(fname,'data','-v7.3'); clc;
    
end