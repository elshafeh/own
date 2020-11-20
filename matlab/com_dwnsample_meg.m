clear ;

for ns = [1:4 8:17]
    for np = 1:3
        
        fname                           = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/yc' num2str(ns) '.pt' num2str(np) '.CnD.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        cfg                             = [];
        cfg.precision                   = 'single';
        data                            = ft_preprocessing(cfg,data_elan);
        
        % DownSample
        cfg                             = [];
        cfg.resamplefs                  = 100;
        cfg.detrend                     = 'no';
        cfg.demean                      = 'no';
        data                            = ft_resampledata(cfg, data);
        
        % Save data
        fname                           = ['/Volumes/h128ssd/alpha_compare/preproc_data/yc' num2str(ns) '.pt' num2str(np) '.CnD.sngl.dwn' num2str(cfg.resamplefs) '.mat'];
        fprintf('saving %s\n',fname);
        save(fname,'data','-v7.3');
        
        fprintf('\n');
        
    end
end