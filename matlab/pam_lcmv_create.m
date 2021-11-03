clear ; clc;

% this is used to beamform the ERFs to choose the voxels with maximum
% activity

for nsuj = 2:21
    
    subjectName                         = ['yc' num2str(nsuj)];
    
    dir_data                            = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
    fname                               = [dir_data subjectName '.VolGrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                               = [dir_data subjectName '.adjusted.leadfield.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                               = [dir_data subjectName '.CnD.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    data{1}                             = data_elan; clear data_elan; % cue lock
    [cue_target]                        = h_getsample(subjectName,'target');
    [cue_button]                        = h_getsample(subjectName,'button');
    
    cfg                                 = [];
    cfg.window                          = [0.4 0.4];
    cfg.begsample                       = cue_target;
    tmp                                 = h_redefinetrial(cfg,data{1}); % all target
    
    target_code                         = mod(tmp.trialinfo-1000,10);
    
    cfg                                 = [];
    cfg.trials                          = find(target_code == 1 | target_code == 3);
    data{2}                             = ft_selectdata(cfg,tmp); % left target
    cfg.trials                          = find(target_code == 2 | target_code == 4);
    data{3}                             = ft_selectdata(cfg,tmp); % right target
    
    clear tmp
    
    cfg                                 = [];
    cfg.window                          = [0.6 0.4];
    cfg.begsample                       = cue_target;
    cfg.begsample                       = cue_button;
    data{4}                             = h_redefinetrial(cfg,data{1}); % button press
    
    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                                 = [];
    cfg.channel                         = data{1}.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    list_covariance                     = [-0.4 0.4; -0.2 0.2; -0.2 0.2; -0.6 0.4];
    
    list_time{1}                        = [-0.2 0; 0 0.2];
    list_time{2}                        = [-0.1 0; 0 0.1];
    list_time{3}                        = [-0.1 0; 0 0.1];
    list_time{4}                        = [-0.6 -0.1; -0.1 0.4];
    
    list_name                           = {'CnD' 'nDLT' 'nDRT' 'nBP'};
    
    for n_d = 1:length(list_name)
        
        % create common spatial filter
        
        cfg_f                           = [];
        cfg_f.covariance_window         = list_covariance(n_d,:);
        cfg_f.leadfield                 = leadfield;
        cfg_f.vol                       = vol;
        spatialfilter                   = h_create_lcmv_common_filter(cfg_f,data{n_d});
        
        for ntime = [1 2]
            
            cfg_s                       = [];
            cfg_s.leadfield             = leadfield;
            cfg_s.vol                   = vol;
            cfg_s.spatialfilter         = spatialfilter;
            cfg_s.time_of_interest      = list_time{n_d}(ntime,:);
            [source,source_name]        = h_lcmv_separate(cfg_s,data{n_d});
            
            dir_out                     = '~/Dropbox/project_me/data/pam/source/';
            
            fname_out                   = [dir_out subjectName '.' list_name{n_d} '.' source_name '.lcmvsource.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'source','-v7.3');
            
        end
        
        clear data_slct
        
    end
end