clear;

file_list                                       = dir('../data/preproc/*.fixlock.fin.mat');
i                                               = 0;
nf                                              = 1;

subjectName                                     = strsplit(file_list(nf).name,'.');
subjectName                                     = subjectName{1};

fname                                           = [file_list(nf).folder filesep file_list(nf).name];
fprintf('Loading %s\n',fname);
load(fname);

cfg                                             = [];
cfg.toilim                                      = [0 1];
data_divided.base_f1                            = ft_redefinetrial(cfg,data);

cfg             = [];
cfg.method      = 'mtmfft'; 
cfg.output      = 'pow';
cfg.taper       = 'hanning';
cfg.pad         = 30;
cfg.tapsmofrq   = 1/cfg.pad;
cfg.foi         = 1:1/cfg.pad:40;
cfg.keeptrials  = 'no';
fft_baseline_f1 = ft_freqanalysis(cfg,data_divided.base_f1);