clear;

file_list                           = dir('../data/source/virtual/s*.mat');

for nfile = 1:length(file_list)
    
    fname                           = [file_list(nfile).folder '/' file_list(nfile).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    cfg                             = [];
    cfg.hilbert                     = 'abs';
    data                            = ft_preprocessing(cfg, data);
    
    if isfield(data,'cfg')
        data                        = rmfield(data,'cfg');
    end
    
    fname                           = [file_list(nfile).folder '/' file_list(nfile).name(1:end-3) 'hilbert.mat'];
    fprintf('\nsaving %s\n',fname);
    save(fname,'data','-v7.3'); clc;
    
end