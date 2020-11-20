clear ; close all;clc;

suj_list                              	= [1:33 35:36 38:44 46:51];
% allpeaks                              	= [];
% 
% for nsuj = 1:length(suj_list)
%     load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
%     allpeaks(nsuj,1)                   	= apeak; clear apeak;
%     allpeaks(nsuj,2)                 	= bpeak; clear bpeak;
% end
% 
% allpeaks(isnan(allpeaks(:,2)),2)      	= nanmean(allpeaks(:,2));
% 
% keep suj_list allpeaks

for ns = 1:length(suj_list)
    
    % lead headshape
    fname                               = ['J:/temp/nback/data/source/volgrid/sub' num2str(suj_list(ns)) '.volgrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        % laod data
        fname                           = ['J:/temp/nback/data/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(suj_list(ns)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % load leadfield
        fname                           = ['J:/temp/nback/data/source/lead/sub' num2str(suj_list(ns)) '.session' num2str(nsession) '.leadfield.0.5cm.mat'];
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
    
    %     list_cond                           = {'decoding.0back.agaisnt.all.alpha.peak.centered.lockedon.target.dwn70.bsl.excl', ...
    %         'decoding.1back.agaisnt.all.alpha.peak.centered.lockedon.target.dwn70.bsl.excl', ...
    %         'decoding.2back.agaisnt.all.alpha.peak.centered.lockedon.target.dwn70.bsl.excl',...
    %         'decoding.0back.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl', ...
    %         'decoding.1back.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl', ...
    %         'decoding.2back.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl'};
    
        list_cond                           = {'alpha.peak.centered.0back.istarget.bsl.exl',...
            'alpha.peak.centered.1back.istarget.bsl.exl',...
            'alpha.peak.centered.2back.istarget.bsl.exl'};
    
    for ncond = 1:length(list_cond)
        
        fname                	= ['J:/temp/nback/data/sens_level_auc/coef/sub' num2str(suj_list(ns)) '.' list_cond{ncond}  '.coef.mat'];
        fname_out            	= ['J:/temp/nback/data/source/coef/sub' num2str(suj_list(ns)) '.' list_cond{ncond}  '.coef.lcmv.mat'];
        
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