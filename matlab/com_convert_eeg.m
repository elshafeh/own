clear ;

for ns = 13 %[1:4 8:17]
    
    data_elan                       = PrepAtt2_fun_eeg2field_cue(['yc' num2str(ns)] ,4,4);
    
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
    fname                           = ['/Volumes/h128ssd/alpha_compare/preproc_data/yc' num2str(ns) '.CnD.eeg.sngl.dwn' num2str(cfg.resamplefs) '.mat'];
    fprintf('saving %s\n',fname);
    save(fname,'data','-v7.3');
    
    fprintf('\n');
    
    clear data data_elan
    
end