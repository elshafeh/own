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
    ext_lock                    = 'firstcuelock';
    fname                       = [subject_folder subjectName '_' ext_lock '_icalean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                       = [subject_folder subjectName '_allTrialInfo.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.prestim                 = 0.5;
    cfg.poststim                = 1;
    cfg.list_lock             	= [2 3 5];
    [data_redefine,list]       	= taco_redefinetrial(cfg,clean_cfg,dataPostICA_clean);
    
    data_concat                	= ft_appenddata([],data_redefine{:});
    
    cfg                     	= [];
    cfg.resamplefs           	= 100;
    cfg.detrend              	= 'no';
    cfg.demean                	= 'yes';
    data                      	= ft_resampledata(cfg, data_concat);
    data                        = rmfield(data,'cfg');
    
    ext_lock                    = 'gratinglock';
    
    fname                       = [subject_folder subjectName '_' ext_lock '_dwnsample' num2str(cfg.resamplefs) 'Hz.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'data','-v7.3');toc;
    
    index                       = data.trialinfo;
    fname                       = [subject_folder subjectName '_' ext_lock '_dwnsample' num2str(cfg.resamplefs) 'Hz_trialinfo.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'index');toc;
    
end