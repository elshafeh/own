clear;clc;

suj_list                             	= [1];

for nsuj = 1
    
    subjectname                     	= ['sub' num2str(suj_list(nsuj))];
    
    load(['J:/nback/grad_orig/grad' num2str(suj_list(nsuj)) '.mat']);
    
    fname                               = ['J:/nback/source/volgrid/' subjectname '.volgrid.0.5cm.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % load leadfield
    fname                               = ['J:/nback/source/lead/sub' num2str(suj_list(nsuj)) '.combined.leadfield.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsess = [1 2]
        fname                           = ['J:/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        cfg                             = [];
        cfg.trials                      = find(data.trialinfo(:,5) == 0);
        tmp{nsess}                      = ft_selectdata(cfg,data);clear data;
        
    end
    
    data                                = ft_appenddata([],tmp{:}); clear tmp;
    data.grad                           = grad;
    
    % down sample
    cfg                                 = [];
    cfg.resamplefs                      = 70;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'yes';
    cfg.baselinewindow                  = [-0.2 0];
    data                                = ft_resampledata(cfg, data);
    
    cfg                                 = [];
    cfg.channel                         = data.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    keep subjectname leadfield vol data
    
    data                                = rmfield(data,'cfg');
    leadfield                         	= rmfield(leadfield,'cfg');
        
    fname_out               = ['D:\Dropbox\project_me\decoding_workshop\' subjectname '.DownsampleData.mat'];
    fprintf('\nsaving %s\n',fname_out);
    save(fname_out,'data','-v7.3');
    
    fname_out               = ['D:\Dropbox\project_me\decoding_workshop\' subjectname '.LeadfieldandVol.mat'];
    fprintf('\nsaving %s\n',fname_out);
    save(fname_out,'leadfield','vol','-v7.3');
    
end