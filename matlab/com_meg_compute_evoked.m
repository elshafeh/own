clear ;

for ns = [1:4 8:17]
    
    for np = 1:3
        
        fname                               = ['/Volumes/h128ssd/alpha_compare/preproc_data/yc' num2str(ns) '.pt' num2str(np) '.CnD.meg.sngl.dwn100.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        cfg                                 = [];
        cfg.demean                          = 'yes';
        cfg.baselinewindow                  = [-0.1 0];
        cfg.lpfilter                        = 'yes';
        cfg.lpfreq                          = 20;
        
        data                                = ft_preprocessing(cfg,data);
        
        avg                                 = ft_timelockanalysis([], data);
        
        cfg                                 = [];
        cfg.feedback                        = 'yes';
        cfg.method                          = 'template';
        cfg.neighbours                      = ft_prepare_neighbours(cfg, avg); close all;
        
        cfg.planarmethod                    = 'sincos';
        avg_planar                          = ft_megplanar(cfg, avg);
        
        avg_comb                            = ft_combineplanar([],avg_planar);
        
        avg_comb                            = rmfield(avg_comb,'cfg');
        avg                                 = rmfield(avg,'cfg');
        
        fname                               = ['/Volumes/h128ssd/alpha_compare/pe/yc' num2str(ns) '.pt' num2str(np) '.CnD.meg.pe.mat'];
        fprintf('Saving %s\n',fname);
        
        save(fname,'avg_comb','-v7.3');
        
    end
end