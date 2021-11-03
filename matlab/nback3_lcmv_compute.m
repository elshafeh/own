clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                             	= [1:33 35:36 38:44 46:51]; % []

for nsuj = 1:length(suj_list)
    
    subjectname                     	= ['sub' num2str(suj_list(nsuj))];
    
    load(['~/Dropbox/project_me/data/nback/grad_orig/grad' num2str(suj_list(nsuj)) '.mat']);
    
    dir_data                            = '~/Dropbox/project_me/data/nback/source/';
    fname                               = [dir_data 'volgrid/' subjectname '.volgrid.0.5cm.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % load leadfield
    fname                               = [dir_data 'lead/sub' num2str(suj_list(nsuj)) '.combined.leadfield.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsess = [1 2]
        
        fname                           = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        cfg                             = [];
        cfg.trials                      = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        tmp{nsess}                      = ft_selectdata(cfg,data);clear data;
        
    end
    
    % add grad info to make ft_sourcecompute happ
    data                                = ft_appenddata([],tmp{:}); clear tmp;
    data.grad                           = grad;
    
    cfg                                 = [];
    cfg.channel                         = data.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    % define windows of interest
    list_time                           = [-0.2 -0.1; 0.07 0.17]; % [-0.3 -0.1; 0.05 0.25];
    
    % create common spatial filter 
    cfg_f                               = [];
    cfg_f.covariance_window             = [min(min(list_time)) max(max(list_time))];
    cfg_f.leadfield                     = leadfield;
    cfg_f.vol                           = vol;
    spatialfilter                       = h_create_lcmv_common_filter(cfg_f,data);
    
    for ntime = 1:size(list_time,1)
        
        cfg_s                           = [];
        cfg_s.leadfield                 = leadfield;
        cfg_s.vol                       = vol;
        cfg_s.spatialfilter             = spatialfilter;
        cfg_s.time_of_interest          = list_time(ntime,:);
        [source,source_name]            = h_lcmv_separate(cfg_s,data);
        
        fname_out                       = ['~/Dropbox/project_me/data/nback/source/lcmv/' subjectname '.allback.allstim'];
        fname_out                       = [fname_out '.' source_name '.lcmvCombined.mat'];
        fprintf('\nsaving %s\n',fname_out);
        
        save(fname_out,'source','-v7.3');
        
    end
    
end