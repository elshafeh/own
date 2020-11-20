clear ; close all;

list_suj                                = [1:33 35:36 38:44 46:51];

for ns = 1:length(list_suj)
    
    % lead headshape
    fname                               = ['J:/temp/nback/data/source/volgrid/sub' num2str(list_suj(ns)) '.volgrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        % laod data
        fname                           = ['K:/nback/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(list_suj(ns)) '.mat'];
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
        cfg.demean                      = 'no';
        data                            = ft_resampledata(cfg, data);
        
        % calculate covariance
        cfg                             = [];
        cfg.covariance                  = 'yes';
        cfg.covariancewindow            = [-0.5 1.5];
        filter_avg                      = ft_timelockanalysis(cfg, data); clear data;
        
        % compute spatial filter
        spatialfilter                   = h_ramaComputeFilter(filter_avg,leadfield,vol);
        
        list_cond                       = {'0back.lockedon.all.dwn70.bsl.excl','1back.lockedon.all.dwn70.bsl.excl'};%,'2back.dwn70.target'};
        
        for ncond = 1:length(list_cond)
            
            %             fname                    	= ['K:/nback/stim_per_cond_coef/sub' num2str(list_suj(ns)) '.sess' num2str(nsession) '.' list_cond{ncond}  '.auc.coef.mat'];
            %             fname_out                   = ['J:/temp/nback/data/source/coef/sub' num2str(list_suj(ns)) '.sess' num2str(nsession) '.' list_cond{ncond}  '.deocdingStim.coef.lcmv.mat'];
            
            fname                    	= ['P:/3015079.01/nback/sens_level_auc/cond/sub' num2str(list_suj(ns)) '.sess' num2str(nsession) '.decoding.' list_cond{nsession}  '.auc.coef.mat'];
            fname_out                   = ['J:/temp/nback/data/source/coef/sub' num2str(list_suj(ns)) '.sess' num2str(nsession) '.' list_cond{nsession} '.deocdingCond.coef.lcmv.mat'];
            
            if exist(fname)
                
                fprintf('loading %s\n',fname);
                load(fname);
                
                data                 	= [];
                
                try
                    data.avg            	= [coef]' * [spatialfilter]';
                catch
                    data.avg            	= [scores]' * [spatialfilter]';
                end
                
                data.avg              	= data.avg';
                data.dimord          	= 'chan_time';
                data.label            	= cellstr(num2str([1:size(spatialfilter,1)]'));
                data.time             	= time_axis;
                
                fprintf('saving %50s\n',fname_out);
                save(fname_out,'data');
                
                clear data
                
            end
        end
    end
end