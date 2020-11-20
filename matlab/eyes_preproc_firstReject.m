clear ; 

subjectName                         = 'pilot05';
dir_data                            = ['../data/' subjectName '/preproc/'];

fname                               = ['../data/' subjectName '/preproc/' subjectName '_cuelock_raw_dwnsample.mat'];
fprintf('Loading %s\n',fname);
load(fname);

% check for outlier bad channels & trials
cfg                                 = [];
cfg.method                          = 'summary';
cfg.megscale                        = 1;
cfg.alim                            = 1e-12;
cfg.metric                          = 'var';
InitRej                             = ft_rejectvisual(cfg,data_downsample);

% check for jumps % press !!! QUIT !!!
cfg                                 = [];
cfg.method                          = 'trial';
% cfg.preproc.demean                  = 'no';
% cfg.preproc.detrend                 = 'yes';
% cfg.megscale                        = 1;
cfg.alim                            = 2e-12;
SecondRej                           = ft_rejectvisual(cfg,InitRej);
SecondRej                           = rmfield(SecondRej,'cfg');

% save trialinfo for re-creation purposes
trialinfo                           = SecondRej.trialinfo;
chaninfo                            = SecondRej.label;
save([dir_data subjectName '_firstRej_trialInfo.mat'],'trialinfo','chaninfo','-v7.3'); 
clear trialinfo chaninfo;

% save data
fname                               = [dir_data subjectName '_cueLock_preICA.mat'];
fprintf('saving %s \n',fname);
save(fname,'SecondRej','-v7.3');