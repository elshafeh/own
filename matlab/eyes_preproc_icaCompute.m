function eyes_preproc_icaCompute

subjectName                     = input('Enter Subject Name     :   ','s');

dir_data                        = ['../data/' subjectName '/preproc/'];
fname                           = [dir_data subjectName '_cueLock_preICA.mat'];
fprintf('Loading %s\n',fname);
load(fname);

cfg                             = [];
cfg.method                      = 'runica';
comp                            = ft_componentanalysis(cfg,SecondRej);

fname                           = [dir_data subjectName '_cueLock_ICAcomp.mat'];
fprintf('Saving %s\n',fname);
save(fname,'comp','-v7.3');