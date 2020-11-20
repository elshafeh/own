function headpos = bil_preproc_hc_cuelock(subjectName)

if isunix
    start_dir                       = '/project';
elseif ispc 
    start_dir                   	= 'P:/';
end

if isunix
    dir_data                       	= [start_dir '3015079.01/data/' subjectName '/'];
elseif ispc 
    dir_data                       	= [start_dir '3015079.01/data/' subjectName '/'];
end

chk                                 = dir([dir_data '/preproc/*firstcue.hcData.300Fs.mat']);

if isempty(chk)
    
    fname                           = [dir_data '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej_trialinfo.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    trl_slct                        = index(:,18);
    
    if strcmp(subjectName,'sub007')
        dsFileName                  = dir(['/home/mrphys/hesels/' subjectName '_*.ds']);
    elseif strcmp(subjectName,'sub037')
        dsFileName                  = dir([start_dir '3015079.01/raw/sub-037/ses-meg01/meg/*.ds']);
    else
        dsFileName                  = dir([start_dir '3015079.01/raw/' subjectName '_*.ds']);
    end
    
    dsFileName                      = [dsFileName.folder '/' dsFileName.name];
    
    cfg                             = [];
    cfg.dataset                     = dsFileName;
    cfg.trialfun                    = 'ft_trialfun_general';
    cfg.trialdef.eventtype          = 'UPPT001';
    cfg.continuous                  = 'yes';
    cfg.precision                   = 'single';
    cfg.channel                     = {'HLC0011','HLC0012','HLC0013', ...
        'HLC0021','HLC0022','HLC0023', ...
        'HLC0031','HLC0032','HLC0033'};
    
    cfg.trialdef.eventvalue         = [11 12 13];
    cfg.trialdef.prestim            = 1;
    cfg.trialdef.poststim           = 7;
    cfg                             = ft_definetrial(cfg);
    
    headpos                         = ft_preprocessing(cfg);
    
    cfg                             = [];
    cfg.trials                      = trl_slct;
    headpos                         = ft_selectdata(cfg,headpos);
    
    cfg                             = [];
    cfg.resamplefs                  = 300;
    cfg.detrend                     = 'no';
    cfg.demean                      = 'no';
    headpos                         = ft_resampledata(cfg, headpos);
    headpos                         = rmfield(headpos,'cfg');
    
    if length(headpos.label) ~= 9
        error('missing channels!');
    end
    
    fname                           = [dir_data 'preproc/' subjectName '.firstcue.hcData.' num2str(cfg.resamplefs) 'Fs.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'headpos','-v7.3');toc;
    
end