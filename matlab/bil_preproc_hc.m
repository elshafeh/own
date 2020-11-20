clear;

suj_list                                = {'sub004'};

for ns = 1:length(suj_list)
    
    subjectName                         = suj_list{ns};
    
    if strcmp(subjectName(1:3),'sub')
        fname                           = ['../data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej_trialinfo.mat'];
    else
        fname                           = ['../data/' subjectName '/preproc/' subjectName '_firstCueLock_postICA.mat'];
    end
    
    fprintf('\nLoading %s\n',fname);
    load(fname);
    
    if strcmp(subjectName(1:3),'sub')
        trl_slct                        = trialinfo(:,18);
    else
        trl_slct                        = dataPostICA.trialinfo;
    end
   
    list_grat{1}                        = [111   112   113   114 121   122   123   124];
    list_grat{2}                        = [211   212   213   214 221   222   223   224];
    
    for ng = 1:2
        
        if strcmp(subjectName,'pil01')
            dsFileName                  = dir(['../raw/' 'pilot01_*.ds']);
        else
            dsFileName                  = dir(['../raw/' subjectName '_*.ds']);
        end
        
        dsFileName                      = [dsFileName.folder '/' dsFileName.name];
        
        cfg                             = [];
        cfg.dataset                     = dsFileName;
        cfg.trialfun                    = 'ft_trialfun_general';
        cfg.trialdef.eventtype          = 'UPPT001';
        cfg.channel                     = 'HLC*' ;
        cfg.continuous                  = 'yes';
        cfg.precision                   = 'single';
        
        cfg.trialdef.eventvalue         = list_grat{ng};
        cfg.trialdef.prestim            = 1;
        cfg.trialdef.poststim           = 1;
        cfg                             = ft_definetrial(cfg);
        
        data_hc{ng}                     = ft_preprocessing(cfg);
        
        cfg                             = [];
        cfg.trials                      = trl_slct;
        cfg.channel                     = {'HLC0011','HLC0012','HLC0013', ...
                                'HLC0021','HLC0022','HLC0023', ...
                                'HLC0031','HLC0032','HLC0033'};
                            
        data_hc{ng}                     = ft_selectdata(cfg,data_hc{ng});
        
        cfg                             = [];
        cfg.resamplefs                  = 100;
        cfg.detrend                     = 'no';
        cfg.demean                      = 'no';
        data_hc{ng}                     = ft_resampledata(cfg, data_hc{ng});
        
        data_hc{ng}.trialinfo           = [data_hc{ng}.trialinfo trl_slct];
        
    end
    
    headpos                             = ft_appenddata([],data_hc{:}); clear data_hc;
    headpos                             = rmfield(headpos,'cfg');
    
    fname                               = ['../data/' subjectName '/preproc/' subjectName '_gratingLock_hc_data.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'headpos','-v7.3');toc;
    
    clearvars -except ns suj_list
    
end