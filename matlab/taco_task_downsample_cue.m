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
    cfg.list_lock             	= 4;
    [data_redefine,list]       	= taco_redefinetrial(cfg,clean_cfg,dataPostICA_clean);
    
    cfg                         = [];
    cfg.latency                 = [-0.5 1];
    data_select                 = ft_selectdata(cfg,dataPostICA_clean);
    
    data_concat                	= ft_appenddata([],data_select,data_redefine{1});
    
    cfg                     	= [];
    cfg.resamplefs           	= 100;
    cfg.detrend              	= 'no';
    cfg.demean                	= 'yes';
    data                      	= ft_resampledata(cfg, data_concat);
    data                        = rmfield(data,'cfg'); clear data_concat data_select data_redefine dataPostICA_clean clean_cfg;
    
    ext_lock                    = 'cuelock';
    
    fname                       = [subject_folder subjectName '_' ext_lock '_dwnsample' num2str(cfg.resamplefs) 'Hz.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'data','-v7.3');toc;
    
    %     Cuecode           	= (order*100) + (type*10) + (attend);
    mtrx                        = data.trialinfo(:,1);
    mtrx(:,2)                   = round(mtrx(:,1) ./ 100);
    mtrx(:,3)                   = round((mtrx(:,1) - (mtrx(:,2).*100)) ./ 10);
    mtrx(:,4)                   = mtrx(:,1) - (mtrx(:,2)*100 + mtrx(:,3)*10);
    
    % order type attend RT correct
    index                       = [mtrx(:,2:4) data.trialinfo(:,[14 16])];
    fname                       = [subject_folder subjectName '_' ext_lock '_dwnsample' num2str(cfg.resamplefs) 'Hz_trialinfo.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'index');toc;
    
end