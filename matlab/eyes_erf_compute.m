clear ;

suj_list                                        = {'pilot03'};

for ns = 1:length(suj_list)
    
    subjectName                                 = suj_list{ns};
    
    dir_data                                    = ['../data/' subjectName '/preproc/'];
    origin_name                                 = 'cueLock_ICAlean_finalrej'; %
    
    fname                                       = [dir_data subjectName '_' origin_name '.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    cfg                                         = [];
    cfg.demean                                  = 'yes';
    cfg.baselinewindow                          = [-0.1 0];
    
    cfg.lpfilter                                = 'yes';
    cfg.lpfreq                                  = 20;
    
    data_all                                    = ft_preprocessing(cfg,dataPostICA_clean);
    
    list_cond                                   = {'open','closed'};
    
    for ncon = 1:length(list_cond)
        
        index_cond                              = {1,2};
        
        cfg                                     = [];
        cfg.trials                              = find(ismember(data_all.trialinfo(:,4),index_cond{ncon}));
        data_sub                                = ft_selectdata(cfg, data_all);
        
        for ncue = 1:3
            
            list_cue                            = {64,128,[64 128]};
            list_name                           = {'left','right','both'};
            
            cfg                                 = [];
            cfg.trials                          = find(ismember(data_sub.trialinfo(:,1),list_cue{ncue}));
            data                                = ft_selectdata(cfg,data_sub);
            
            avg                                 = ft_timelockanalysis([], data);
            
            cfg                                 = [];
            cfg.feedback                        = 'yes';
            cfg.method                          = 'template';
            cfg.neighbours                      = ft_prepare_neighbours(cfg, avg); close all;
            
            cfg.planarmethod                    = 'sincos';
            avg_planar                          = ft_megplanar(cfg, avg);
            
            avg_comb                            = ft_combineplanar([],avg_planar);
            avg_comb                            = rmfield(avg_comb,'cfg');
            
            dir_data                            = ['../data/' subjectName '/erf/'];
            mkdir(dir_data);
            
            ext_name                            = [lower(origin_name(1:7)) '.erf.comb.' list_cond{ncon} '.' list_name{ncue}];
            
            fname                               = [dir_data subjectName '_' ext_name '.mat'];
            fprintf('\nSaving %s\n\n',fname);
            save(fname,'avg_comb','-v7.3');
            
        end
        
    end
end