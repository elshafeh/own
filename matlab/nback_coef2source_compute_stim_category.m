clear ; close all;

list_suj                                = [1:33 35:36 38:44 46:51];

for ns = 1:length(list_suj)
    
    % lead headshape
    fname                               = ['J:/temp/nback/data/source/volgrid/sub' num2str(list_suj(ns)) '.volgrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        % laod data
        fname                           = ['J:/temp/nback/data/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(list_suj(ns)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % load leadfield
        fname                           = ['J:/temp/nback/data/source/lead/sub' num2str(list_suj(ns)) '.session' num2str(nsession) '.leadfield.0.5cm.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % down sample
        cfg                             = [];
        cfg.resamplefs                  = 70;
        cfg.detrend                     = 'no';
        cfg.demean                      = 'yes';
        cfg.baselinewindow              = [-0.2 0];
        data                            = ft_resampledata(cfg, data);
        
        % calculate covariance
        cfg                             = [];
        cfg.covariance                  = 'yes';
        cfg.covariancewindow            = [-0.1 2];
        filter_avg                      = ft_timelockanalysis(cfg, data); clear data;
        
        % compute spatial filter
        spatialfilter                   = h_ramaComputeFilter(filter_avg,leadfield,vol);
        
        list_cond                       = {'0back','1back','2back'};
        
        for ncond = 1:length(list_cond)
            
            fname                       = ['J:/temp/nback/data/stim_category/sub' num2str(list_suj(ns)) '.sess' num2str(nsession)  ... 
                '.' list_cond{ncond}  '.istarget.bsl.dwn70.excl.coef.mat'];
            
            
            if exist(fname)
                
                fprintf('loading %s\n',fname);
                load(fname);
                
                data                 	= [];
                data.avg              	= [scores]' * [spatialfilter]';
                data.avg              	= data.avg';
                data.dimord            	= 'chan_time';
                data.label            	= cellstr(num2str([1:size(spatialfilter,1)]'));
                data.time             	= time_axis;
                
                fname_out             	= [fname(1:end-4) '.lcmv.mat'];
                fprintf('saving  %50s\n',fname_out);
                save(fname_out,'data');
                
                clear data
                
            end
        end
        
        clear spatialfilter
        
    end
end