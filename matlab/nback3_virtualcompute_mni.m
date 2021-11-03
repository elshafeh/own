clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                 = ['sub' num2str(suj_list(nsuj))];
    
    load(['~/Dropbox/project_me/data/nback/prepro/vis/grad' num2str(suj_list(nsuj)) '.mat']);
    
    fname                       = ['~/Dropbox/project_me/data/nback/source/volgrid/' subjectname '.volgrid.0.5cm.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % load leadfield
    fname                       = ['~/Dropbox/project_me/data/nback/source/lead/sub' num2str(suj_list(nsuj)) '.combined.leadfield.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsess = [1 2]
        
        fname                   = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        cfg                     = [];
        cfg.trials              = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,4) ~= 1);
        tmp{nsess}              = ft_selectdata(cfg,data);clear data;
        
    end
    
    data                        = ft_appenddata([],tmp{:}); clear tmp;
    data.grad                   = grad;

    % down-sample
    cfg                         = [];
    cfg.resamplefs              = 100;
    cfg.detrend                 = 'no';
    cfg.demean                  = 'no';
    data                        = ft_resampledata(cfg, data); clear dataPostICA_clean
    
    covariance_window           = [-1 1];
    
    cfg                         = [];
    cfg.covariance              = 'yes';
    cfg.covariancewindow        = covariance_window;
    avg                         = ft_timelockanalysis(cfg,data);
    
    % -- create spatial filter
    cfg                         = [];
    cfg.method                  = 'lcmv';
    cfg.sourcemodel             = leadfield;
    cfg.headmodel               = vol;
    cfg.lcmv.keepfilter         = 'yes';
    cfg.lcmv.fixedori           = 'yes';
    cfg.lcmv.projectnoise       = 'yes';
    cfg.lcmv.keepmom            = 'yes';
    cfg.lcmv.projectmom         = 'yes';
    cfg.lcmv.lambda             = '5%' ;
    source                      =  ft_sourceanalysis(cfg, avg);
        
    cfg                         = [];
    cfg.channel                 = data.label;
    leadfield                   = ft_selectdata(cfg,leadfield);
    
    dir_field                   = '~/github/fieldtrip/template/atlas/aal/';
    atlas                       = ft_read_atlas([dir_field 'ROI_MNI_V4.nii']);
    atlas                       = ft_convert_units(atlas,'cm');
    
    source.pos                  = grid.MNI_pos;
    
    cfg                         = [];
    cfg.interpmethod            = 'nearest'; %
    cfg.parameter               = 'tissue';
    atlas_source                = ft_sourceinterpolate(cfg, atlas, source);
    
    cfg                         = [];
    cfg.method                  = 'svd';
    cfg.svd.covariancewindow    = covariance_window;
    cfg.parcellation            = 'tissue';
    
    cfg.parcel                  = {'Calcarine_L' 'Calcarine_R' 'Occipital_Sup_L' 'Occipital_Sup_R' ...
        'Occipital_Mid_L' 'Occipital_Mid_R' 'Occipital_Inf_L' 'Occipital_Inf_R' 'Parietal_Sup_L' 'Parietal_Sup_R' ...
        'Parietal_Inf_L' 'Parietal_Inf_R'};
    
    data                        = ft_virtualchannel(cfg, data, source,atlas_source);
    
    data                        = rmfield(data,'cfg');
    
    fname                       = ['~/Dropbox/project_me/data/nback/virt/sub' num2str(suj_list(nsuj)) '.mni.roi.mat'];
    fprintf('\nsaving %s\n',fname);
    save(fname,'data','-v7.3');
    
    clear data;
    
end