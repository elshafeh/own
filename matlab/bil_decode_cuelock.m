clear ;

subjectName                         = 'pil06';
dir_data                            = ['../data/' subjectName '/preproc/'];

fname                               = [dir_data subjectName '_firstCueLock_ICAlean_finalrej.mat'];
fprintf('Loading %s\n',fname);
load(fname);

fname                               = [dir_data subjectName '_allTrialInfo.mat'];
fprintf('Loading %s\n',fname);
load(fname);

[offset]                            = h_adjustrial(dataPostICA_clean,all_cfg);
offset                              = [zeros(length(offset),1) offset(:,3)];

for ix = 1:2
    
    cfg                             = [];
    cfg.window                      = 1;
    cfg.begsample                   = offset(:,ix);
    newdata{ix}                     = h_redefinetrial(cfg,dataPostICA_clean);
    
    newdata{ix}.trialinfo           = h_create_cuetrialinfo(newdata{ix}.trialinfo,ix);
    
end

data                                = ft_appenddata([],newdata{1},newdata{2});

clearvars -except data subjectName dir_data

cfg                                 = [];
cfg.resamplefs                      = 100;
cfg.detrend                         = 'no';
cfg.demean                          = 'yes';
data                                = ft_resampledata(cfg, data);
data                                = rmfield(data,'cfg');

ext_lock                            = '_2cueLock_';

fname                               = [dir_data subjectName ext_lock 'dwnsample100Hz.mat'];
fprintf('Saving %s\n',fname);
tic;save(fname,'data','-v7.3');toc;

index                               = data.trialinfo;
fname                               = [dir_data subjectName ext_lock 'trialinfo.mat'];
fprintf('Saving %s\n',fname);
tic;save(fname,'index');toc;