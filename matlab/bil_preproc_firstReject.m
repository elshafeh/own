clear ; close all;clc;

% first inspection of data using
% ft_rejectvisual im 'summary' and 'trial' mode

if ispc
    start_dir = 'P:/';
else
    start_dir = '/project/';
end

% check all -raw files
file_list                           = dir([start_dir '3015079.01/data/sub*/preproc/*_firstcuelock_raw_dwnsample.mat']);
i                                   = 0;

for nf = 1:length(file_list)
    sub                             = file_list(nf).name(1:6);
    chk1                         	= dir([start_dir '3015079.01/data/' sub '/preproc/*_firstCueLock_ICAlean_finalrej.mat']);
    chk2                           	= dir([start_dir '3015079.01/data/' sub '/preproc/*_firstCueLock_preICA.mat']);
    
    % check if this stip hasn't been done before
    if isempty(chk1) && isempty(chk2)
        i                           = i +1;
        list{i}                     = sub;
    end
end

% make a list for experimenter to choose from
[indx,~]                            = listdlg('ListString',list,'ListSize',[100,100]);

subjectName                         = list{indx};
dir_data                            = [start_dir '3015079.01/data/' subjectName '/preproc/'];

fname                               = [dir_data subjectName '_firstcuelock_raw_dwnsample.mat'];
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
cfg.preproc.demean                  = 'yes';
cfg.megscale                        = 1;
cfg.alim                            = 2e-12;
SecondRej                           = ft_rejectvisual(cfg,InitRej);
% press !!! QUIT !!!
SecondRej                           = rmfield(SecondRej,'cfg');

% save trialinfo for re-creation purposes
trialinfo                           = SecondRej.trialinfo;
chaninfo                            = SecondRej.label;

% save data

save([dir_data subjectName '_firstRej_trialInfo.mat'],'trialinfo','chaninfo','-v7.3'); 
clear trialinfo chaninfo;

save([dir_data subjectName '_firstCueLock_preICA.mat'],'SecondRej','-v7.3');

a                                   = length(SecondRej.trialinfo);
b                                   = length(data_downsample.trialinfo);

fprintf('\ndone with %.2f trials remaining!\n',a/b);