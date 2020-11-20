clear ; close all;clc;

suj_list                              	= [1:33 35:36 38:44 46:51];

for ns = 1:length(suj_list)
    
    % lead headshape
    fname                               = ['J:/nback/source/volgrid/sub' num2str(suj_list(ns)) '.volgrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        % load data
        fname                     	= ['J:/nback/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(suj_list(ns)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % down sample
        cfg                        	= [];
        cfg.resamplefs             	= 70;
        cfg.detrend               	= 'no';
        cfg.demean                	= 'yes';
        cfg.baselinewindow         	= [-0.2 0];
        data_carr{nsession}         = ft_resampledata(cfg, data); clear data;
        
    end
    
    data                            = ft_appenddata([],data_carr{:});clear data_carr
    
    % load grad
    fname = ['D:\Dropbox\project_nback\data\grad_orig\grad' num2str(suj_list(ns)) '.mat'];
    load(fname);
    data.grad                       = grad; %clear grad;
    
    % load leadfield
    fname                           = ['J:/nback/source/lead/sub' num2str(suj_list(ns)) '.combined.leadfield.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % calculate covariance
    cfg                             = [];
    cfg.covariance                  = 'yes';
    cfg.covariancewindow            = [-0.5 1.5];
    filter_avg                      = ft_timelockanalysis(cfg, data); clear data;
    
    % compute spatial filter
    spatialfilter                   = h_ramaComputeFilter(filter_avg,leadfield,vol); clear filter_avg
    
    list_cond                       = {'beta.peak.centered.1back.istarget.bsl.exl' 'beta.peak.centered.1back.isfirst.bsl.exl'};
    
    for ncond = 1:length(list_cond)
        
        fname                       = ['J:/nback/sens_level_auc/coef/sub' num2str(suj_list(ns)) '.' list_cond{ncond}  '.coef.mat'];
        fname_out                   = ['J:/nback/source/coef/sub' num2str(suj_list(ns)) '.' list_cond{ncond}  '.coef.combinedlead.lcmv.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        data                        = [];
        data.avg                    = [scores]' * [spatialfilter]';
        data.avg                    = data.avg';
        data.dimord                 = 'chan_time';
        data.label                  = cellstr(num2str([1:size(spatialfilter,1)]'));
        data.time                   = time_axis;
        
        fprintf('saving %50s\n',fname_out);
        save(fname_out,'data'); clear data nsess;
        
    end
    
end

%     list_cond                       = {'alpha.peak.centered.1back.istarget.bsl.exl', ...
%         'alpha.peak.centered.2back.istarget.bsl.exl', ...
%         'beta.peak.centered.1back.istarget.bsl.exl', ...
%         'beta.peak.centered.2back.istarget.bsl.exl',...
%         'alpha.peak.centered.1back.isfirst.bsl.exl', ...
%         'alpha.peak.centered.2back.isfirst.bsl.exl', ...
%         'beta.peak.centered.1back.isfirst.bsl.exl', ...
%         'beta.peak.centered.2back.isfirst.bsl.exl'};

%     list_cond                      	= {'decoding.0back.agaisnt.all.alpha.peak.centered.lockedon.target.dwn70.bsl.excl', ...
%         'decoding.1back.agaisnt.all.alpha.peak.centered.lockedon.target.dwn70.bsl.excl', ...
%         'decoding.2back.agaisnt.all.alpha.peak.centered.lockedon.target.dwn70.bsl.excl',...
%         'decoding.0back.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl', ...
%         'decoding.1back.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl', ...
%         'decoding.2back.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl',...
%         'alpha.peak.centered.0back.istarget.bsl.exl',...
%         'alpha.peak.centered.1back.istarget.bsl.exl',...
%         'alpha.peak.centered.2back.istarget.bsl.exl'};

%         list_cond                      	= {'decoding.rt.0back.dwn70.bsl', ...
%         'decoding.rt.0back.alpha.peak.centered.bsl', ...
%         'decoding.rt.0back.beta.peak.centered.bsl',...
%         'decoding.rt.1back.dwn70.bsl', ...
%         'decoding.rt.1back.alpha.peak.centered.bsl', ...
%         'decoding.rt.1back.beta.peak.centered.bsl',...
%         'decoding.rt.2back.dwn70.bsl', ...
%         'decoding.rt.2back.alpha.peak.centered.bsl', ...
%         'decoding.rt.2back.beta.peak.centered.bsl'};


%     list_cond                       = {'decoding.0back.agaisnt.all.lockedon.target.dwn70.bsl.excl', ...
%         'decoding.1back.agaisnt.all.lockedon.target.dwn70.bsl.excl', ...
%         'decoding.2back.agaisnt.all.lockedon.target.dwn70.bsl.excl'};

% {'decoding.1back.agaisnt.all.beta.peak.centered.lockedon.first.dwn70.bsl.excl', ...
%         'decoding.2back.agaisnt.all.beta.peak.centered.lockedon.first.dwn70.bsl.excl', ...
%         'decoding.1back.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl',...
%         'decoding.2back.agaisnt.all.beta.peak.centered.lockedon.target.dwn70.bsl.excl'};