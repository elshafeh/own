clear;

suj_list                = [1:4 8:17] ;

for ns = 1:length(suj_list)
    
    suj                 = ['yc' num2str(suj_list(ns))] ;
    cond_main           = 'CnD.com90roi.meg';
    
    fname               = ['/Volumes/h128ssd/alpha_compare/lcmv/' suj '.' cond_main '.mat'];
    fprintf('Loading %s\n\n',fname);
    load(fname);
    
    cfg                 = [] ;
    cfg.output          = 'pow';
    cfg.method          = 'mtmconvol';
    cfg.keeptrials      = 'yes';
    cfg.pad             = 'maxperlen';
    cfg.taper           = 'hanning';

    cfg.foi             = 1:1:20;
    cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
    cfg.toi             = -2:0.05:2;
    cfg.tapsmofrq       = 0 ;
    
    freq                = ft_freqanalysis(cfg,data);
    freq                = rmfield(freq,'cfg');
    
    fname               = ['/Volumes/h128ssd/alpha_compare/tf/' suj '.' cond_main '.mtm.mat'];
    fprintf('Saving %s\n\n',fname);
    save(fname,'freq','-v7.3');
    
end