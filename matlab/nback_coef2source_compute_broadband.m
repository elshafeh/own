clear ; close all;

list_suj                                = [1:33 35:36 38:44 46:51];

for ns = 1:length(list_suj)
    
    % lead headshape
    fname                               = ['J:/nback/source/volgrid/sub' num2str(list_suj(ns)) '.volgrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        % laod data
        fname                           = ['J:/nback/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(list_suj(ns)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % load leadfield
        fname                           = ['J:/nback/source/lead/sub' num2str(list_suj(ns)) '.session' num2str(nsession) '.leadfield.0.5cm.mat'];
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
        cfg.covariancewindow            = [-0.5 1.5];
        filter_avg                      = ft_timelockanalysis(cfg, data); clear data;
        
        % compute spatial filter
        spatialfilter_carr{nsession}   	= h_ramaComputeFilter(filter_avg,leadfield,vol); clear filter_avg
        
    end
    
    list_cond                	= {'2back.istarget.bsl.exl.dwn70', ...
        '1back.istarget.bsl.exl.dwn70'};
    
    for ncond = 1:length(list_cond)
        
        fname                	= ['J:/nback/sens_level_auc/coef/sub' num2str(list_suj(ns)) '.' list_cond{ncond}  '.coef.mat'];
        fname_out            	= ['J:/nback/source/coef/sub' num2str(list_suj(ns)) '.' list_cond{ncond}  '.coef.lcmv.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        for nsess = 1:2
            data{nsess}         = [];
            data{nsess}.avg  	= [scores]' * [spatialfilter_carr{nsess}]';
            data{nsess}.avg    	= data{nsess}.avg';
            data{nsess}.dimord 	= 'chan_time';
            data{nsess}.label  	= cellstr(num2str([1:size(spatialfilter_carr{nsess},1)]'));
            data{nsess}.time   	= time_axis;
        end
        
        data                    = ft_timelockgrandaverage([],data{:});
        data                    = rmfield(data,'cfg');
        
        fprintf('saving %50s\n',fname_out);
        save(fname_out,'data'); clear data nsess;
        
    end
end