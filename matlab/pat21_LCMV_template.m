clear; clc ;

suj_list  = [1:4 8:17];

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))];
    
    for b = 1:3
        
        cnd = {'VCND','NCnD'};
        
        for c = 1:length(cnd)
            
            fname_in = [suj '.pt' num2str(b) '.' cnd{c}];
            fprintf('\n\nLoading %50s \n\n',fname_in);
            load(['../data/' suj '/elan/' fname_in '.mat'])
            data_carr{c}         = data_elan ;
            clear data_elan
            
        end
        
        data_f = ft_appenddata([],data_carr{:});
       
        clear data_carr
        
        cfg                 = [];
        cfg.lpfilter        = 'yes';
        cfg.lpfreq          = 20 ;
        data                = ft_preprocessing(cfg,data_f);
        
        clear data_f
            
        cfg             = [];
        cfg.latency     = [-0.4 1.1];
        data4filt       = ft_selectdata(cfg,data);
        
        cfg                     = [];
        cfg.covariance          = 'yes';
        cfg.covariancewindow    = [-0.4 1.1];
        avg4filt                = ft_timelockanalysis(cfg,data4filt);
        
        clear data4filt
        
        load(['../data/' suj '/headfield/' suj '.pt' num2str(b) '.adjusted.leadfield.1cm.mat']);
        load(['../data/' suj  '/headfield/' suj '.VolGrid.1cm.mat']);
        
        cfg                         = [];
        cfg.method                  = 'lcmv';
        cfg.grid                    = leadfield;
        cfg.headmodel               = vol;
        cfg.lcmv.keepfilter         = 'yes';
        cfg.lcmv.fixedori           = 'yes';
        cfg.lcmv.projectnoise       = 'yes';
        cfg.lcmv.keepmom            = 'yes';
        cfg.lcmv.projectmom         = 'yes';
        cfg.lcmv.lambda             = '5%';
        source4filt                 = ft_sourceanalysis(cfg, avg4filt);
        
        common_filter = source4filt.avg.filter;
        
        clear source4filt avg4filt
        
        poi_list = [-0.2 0.5:0.1:1.1];
        
        for d = 1:length(poi_list);
            
            cfg = [];
            cfg.latency = [poi_list(d) poi_list(d)+0.1];
            poi = ft_selectdata(cfg,data);
            
            cfg = [];
            cfg.covariance = 'yes';
            cfg.covariancewindow = 'all';
            avg = ft_timelockanalysis(cfg,poi);
            
            clear poi
            
            cfg                         = [];
            cfg.method                  = 'lcmv';
            cfg.grid                    = leadfield;
            cfg.headmodel               = vol;
            cfg.lcmv.fixedori           = 'yes';
            cfg.lcmv.projectnoise       = 'yes';
            cfg.lcmv.keepmom            = 'yes';
            cfg.lcmv.projectmom         = 'yes';
            cfg.lcmv.lambda             = '5%';
            cfg.grid.filter             = common_filter;
            source                      = ft_sourceanalysis(cfg, avg);
            
            clear avg 
            
            if poi_list(d) < 0
                ext= 'm';
            else
                ext='p';
            end
            
            lm_ext = [ext num2str(abs(poi_list(d))*1000) ext num2str((abs(poi_list(d))+0.1)*1000)];
            
            f_name_source = [suj '.pt' num2str(b) '.' cnd{c} '.' lm_ext '.lcmv.source'];
            fprintf('\n\nSaving %50s \n\n',f_name_source);
            save(['../data/' suj '/source/' f_name_source '.mat'],'source','-v7.3');
            
            clear source
            
        end
        
        clear data4filt
        
    end
    
end