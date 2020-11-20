clear ;

for ns = [1:4 8:17]
    
    dir_out                             = ['/Volumes/heshamshung/alpha_compare/lcmv_mtm/yc' num2str(ns)];
    mkdir(dir_out)
    
    list_orig                           = {'CnD.com90roi.meg','CnD.com90roi.eeg'};
    
    for ndata = 1:length(list_orig)
        
        % load data
        fname                           = ['/Volumes/heshamshung/alpha_compare/lcmv/yc' num2str(ns) '.' list_orig{ndata} '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        data.trialinfo(:)               = ndata;
        tmp{ndata}                      = data; clear data;
        
    end
    
    data                                = ft_appenddata([],tmp{:}); clear tmp;
    
    
    cfg                                 = [];
    cfg.resamplefs                      = 50;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'no';
    data                                = ft_resampledata(cfg, data);
    data                                = rmfield(data,'cfg');
    
    fname                               = ['/Volumes/heshamshung/alpha_compare/lcmv/yc' num2str(ns) '.meeg.mat'];
    fprintf('save %s\n',fname);
    save(fname,'data','-v7.3');
    
    clear data;
    
end