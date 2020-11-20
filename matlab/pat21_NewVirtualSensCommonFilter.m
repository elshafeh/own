clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']); clc ;
    
    cnd = {'CnD'};
    
    for prt = 1:3
        
        for cnd_cue = 1:length(cnd)
            fname = ['../data/elan/' suj '.pt' num2str(prt) '.' cnd{cnd_cue} '.mat'];
            fprintf('\nLoading %20s\n',fname);
            load(fname);
            tmp{cnd_cue} = data_elan ; clear data_elan ;
        end
        
        if length(tmp) > 1
            data_elan = ft_appenddata([],tmp{:}) ; clear tmp ;
        else
            data_elan = tmp{1}; clear tmp;
        end
        
        list_filt                       = [1 20;40 120;1 120];
        
        cfg                         = [];
        cfg.latency                 = [-0.8 2];
        data_elan                   = ft_selectdata(cfg,data_elan);
        
        extCovFilt1                 = ['m' num2str(abs(cfg.latency(1)*1000))];
        extCovFilt2                 = ['p' num2str(abs(cfg.latency(2)*1000)) 'ms'];
        extCov                      = [extCovFilt1 extCovFilt2];
        
        for nfilt = 1:size(list_filt,1)
            
            cfg                         = [];
            cfg.bpfilter                = 'yes';
            cfg.bpfreq                  = list_filt(nfilt,:);
            dataica                     = ft_preprocessing(cfg,data_elan);
            
            extFreqFilt                 = [num2str(list_filt(nfilt,1)) 't' num2str(list_filt(nfilt,2)) 'Hz'];
            
            cfg                         = [];
            cfg.covariance              = 'yes';
            cfg.covariancewindow        = 'all';
            avg                         = ft_timelockanalysis(cfg,dataica);
            
            clear dataica
            
            load(['../data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']); clc ;
            
            cfg                         =   [];
            cfg.method                  =   'lcmv';
            cfg.grid                    =   leadfield;
            cfg.headmodel               =   vol;
            cfg.lcmv.keepfilter         =   'yes';cfg.lcmv.fixedori           =   'yes';
            cfg.lcmv.projectnoise       =   'yes';cfg.lcmv.keepmom            =   'yes';
            cfg.lcmv.projectmom         =   'yes';cfg.lcmv.lambda             =   '15%';
            source                      =   ft_sourceanalysis(cfg, avg);
            
            clear avg ; spatialfilter   = cat(1,source.avg.filter{:});  clear source cfg
            
            fname_out = [suj '.pt' num2str(prt) '.Filt4VirtualSens.CoV.' extCov '.freq.' extFreqFilt];
            
            fprintf('\n\nSaving %50s \n\n',fname_out);
            
            save(['../data/filter/' fname_out '.mat'],'spatialfilter','-v7.3')
            
        end
        
        clear spatialfilter leadfield data_elan
        
    end
end