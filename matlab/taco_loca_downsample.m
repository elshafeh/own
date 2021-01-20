clear ; clc;

if ispc
    start_dir                   = 'D:/Dropbox/project_me/data/taco/';
else
    start_dir                   = '~/Dropbox/project_me/data/taco/';
end

suj_list                        = {'tac001'};

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    subject_folder              = [start_dir 'preproc/'];
    ext_lock                    = 'localizerlock';
    fname                       = [subject_folder subjectName '_' ext_lock '_icalean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.latency                 = [-0.2 1.2];
    dataPostICA_clean           = ft_selectdata(cfg,dataPostICA_clean);
    
    cfg                     	= [];
    cfg.resamplefs           	= 100;
    cfg.detrend              	= 'no';
    cfg.demean                	= 'yes';
    data                      	= ft_resampledata(cfg, dataPostICA_clean);
    data                        = rmfield(data,'cfg');
    
    fname                       = [subject_folder subjectName '_' ext_lock '_dwnsample' num2str(cfg.resamplefs) 'Hz.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'data','-v7.3');toc;
    
    index                       = data.trialinfo;
    fname                       = [subject_folder subjectName '_' ext_lock '_dwnsample' num2str(cfg.resamplefs) 'Hz_trialinfo.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'index');toc;
    
end