clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                        = [1:33 35:36 38:44 46:51];
load ../data/stock/template_grid_0.5cm.mat ;

for nsuj = 1:length(suj_list)
    
    subjectname                 = ['sub' num2str(suj_list(nsuj))];
    
    load(['~/Dropbox/project_me/data/nback/grad_orig/grad' num2str(suj_list(nsuj)) '.mat']);
    
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
        cfg.trials              = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        tmp{nsess}              = ft_selectdata(cfg,data);clear data;
        
    end
    
    data                        = ft_appenddata([],tmp{:}); clear tmp;
    data.grad                   = grad;
    
    % down-sample
    cfg                         = [];
    cfg.resamplefs              = 70;
    cfg.detrend                 = 'no';
    cfg.demean                  = 'no';
    data                        = ft_resampledata(cfg, data); clear dataPostICA_clean
    
    trialinfo(:,1)           	= data.trialinfo(:,1); % condition
    trialinfo(:,2)           	= data.trialinfo(:,3); % stim category
    trialinfo(:,3)            	= rem(data.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)           	= 1:length(data.trialinfo); % trial indices to match with bin
    
    covariance_window           = [-1 2];
    
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
    spatialfilter             	=  cat(1,source.avg.filter{:});
    
    cfg                         = [];
    cfg.channel                 = data.label;
    leadfield                   = ft_selectdata(cfg,leadfield);
    
    fname_in                  	= ['~/Dropbox/project_me/data/nback/virt/' subjectname '.wallis.index.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    data                      	= h_virt_compute(data,index_name,index_vox,spatialfilter,template_grid);
    
    fname                       = ['~/Dropbox/project_me/data/nback/virt/sub' num2str(suj_list(nsuj)) '.wallis.roi.mat'];
    fprintf('\nsaving %s\n',fname);
    save(fname,'data','-v7.3');

    index                       = trialinfo;
    
    fname                       = ['~/Dropbox/project_me/data/nback/virt/sub' num2str(suj_list(nsuj)) '.wallis.trialinfo.mat'];
    fprintf('\nsaving %s\n',fname);
    save(fname,'index');

    
    keep nsuj suj_list template_grid
    
end

%     dir_field                   = '~/github/fieldtrip/template/atlas/afni/';
%     atlas                       = ft_read_atlas([dir_field 'TTatlas+tlrc.HEAD']);
%     atlas                       = ft_convert_units(atlas,'cm');
%
%     source.pos                  = grid.MNI_pos;
%
%     cfg                         = [];
%     cfg.interpmethod            = 'nearest'; %
%     cfg.parameter               = 'brick1';
%     atlas_source                = ft_sourceinterpolate(cfg, atlas, source);
%
%     cfg                         = [];
%     cfg.method                  = 'svd';
%     cfg.svd.covariancewindow    = covariance_window;
%     cfg.parcellation            = 'brick1';
%     cfg.parcel                  = {'Brodmann area 5' 'Brodmann area 7' 'Brodmann area 17' 'Brodmann area 18' 'Brodmann area 19' }; %
%     data                        = ft_virtualchannel(cfg, data, source,atlas_source);