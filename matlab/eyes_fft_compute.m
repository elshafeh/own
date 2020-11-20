clear;

suj_list                                        = {'pilot03'};

for ns = 1:length(suj_list)
    
    subjectName                                 = suj_list{ns};
    
    dir_data                                    = ['../data/' subjectName '/preproc/'];
    origin_name                                 = 'cueLock_ICAlean_finalrej';
    
    fname                                       = [dir_data subjectName '_' origin_name '.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    data_axial                                  = dataPostICA_clean; clear dataPostICA_clean;
    data_planar                                 = h_ax2plan(data_axial);
    
    list_cond                                   = {'open','closed'};
    
    for ncon = 1:length(list_cond)
        
        index_cond                              = {1,2};
        
        cfg                                     = [];
        cfg.trials                              = find(ismember(data_planar.trialinfo(:,4),index_cond{ncon}));
        cfg.latency                             = [0.4 0.9]; 
        data                                    = ft_selectdata(cfg, data_planar);
        
        list_cue                                = {'both'}; % {'left','right'};
        index_cue                               = {[64 128]}; % {64,128};
        
        for ncue = 1:length(list_cue)
            
            cfg                                 = [] ;
            cfg.output                          = 'pow';
            cfg.method                          = 'mtmfft';
            
            cfg.trials                          = find(ismember(data.trialinfo(:,1),index_cue{ncue}));
            
            cfg.keeptrials                      = 'yes';
            cfg.pad                             = 1;
            cfg.foi                             = 1:1/cfg.pad:30;
            cfg.taper                           = 'hanning';
            cfg.tapsmofrq                       = 0 ;
            freq                                = ft_freqanalysis(cfg,data);
            
            freq                                = rmfield(freq,'cfg');
            
            cfg                                 = []; cfg.method     = 'sum';
            freq_comb                           = ft_combineplanar(cfg,freq);
            
            dir_data                            = ['../data/' subjectName '/tf/'];
            mkdir(dir_data);
            
            ext_name                            = [lower(origin_name(1:7)) '.fft.comb.' list_cond{ncon} '.' list_cue{ncue}];
            
            fname                               = [dir_data subjectName '_' ext_name '.mat'];
            fprintf('Saving %s\n',fname);
            
            save(fname,'freq_comb','-v7.3');
            
        end
        
    end
    
end