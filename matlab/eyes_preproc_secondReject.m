clear ;

subjectName                         = 'pilot03';
dir_data                            = ['../data/' subjectName '/preproc/'];

fname                               = [dir_data subjectName '_cueLock_ICAlean.mat'];
fprintf('Loading %s\n',fname);
load(fname);

cfg                                 = [];
cfg.method                          = 'summary';
cfg.metric                          = 'var';
cfg.megscale                        = 1;
cfg.alim                            = 1e-12;
postICA_Rej                         = ft_rejectvisual(cfg,dataPostICA);

cfg                                 = [];
cfg.channel                         = 'MEG';
RejCfg                              = ft_databrowser(cfg,postICA_Rej);

dataPostICA_clean                   = ft_rejectartifact(RejCfg,postICA_Rej);

dataPostICA_clean                   = rmfield(dataPostICA_clean,'cfg');
fname                               = [dir_data subjectName '_cueLock_ICAlean_finalrej.mat'];
fprintf('Saving %s\n',fname);
save(fname,'dataPostICA_clean','-v7.3');

trialinfo                           = dataPostICA_clean.trialinfo;
fname                               = [dir_data subjectName '_cueLock_ICAlean_finalrej_trialinfo.mat'];
fprintf('Saving %s\n',fname);
save(fname,'trialinfo','-v7.3');

fprintf('Done\n');