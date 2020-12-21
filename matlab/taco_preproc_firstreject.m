function taco_preproc_firstreject

% first inspection of data using
% ft_rejectvisual im 'summary' and 'trial' mode

% make a list for experimenter to choose from
lock_list                           = {'firstcuelock' 'localizerlock'};
[indx,~]                            = listdlg('ListString',lock_list,'ListSize',[100,100]);
ext_lock                            = lock_list{indx};

if ispc
    start_dir = 'D:/Dropbox/project_me/data/taco/';
else
    start_dir = '~/Dropbox/project_me/data/taco/';
end

% check all -raw files
file_list                           = dir([start_dir 'preproc/*' ext_lock '_raw_dwnsample.mat']);
i                                   = 0;

for nf = 1:length(file_list)
    
    sub                             = file_list(nf).name(1:6);
    chk1                         	= dir([start_dir 'preproc/*' ext_lock '_icalean_finalrej.mat']);
    chk2                           	= dir([start_dir 'preproc/*' ext_lock '_preica.mat']);
    
    % check if this stip hasn't been done before
    if isempty(chk1) && isempty(chk2)
        i                           = i +1;
        list{i}                     = sub;
    end
end

% make a list for experimenter to choose from
[indx,~]                            = listdlg('ListString',list,'ListSize',[100,100]);

subjectName                         = list{indx};
dir_data                            = [start_dir 'preproc/'];

fname                               = [dir_data subjectName '_' ext_lock '_raw_dwnsample.mat'];
fprintf('Loading %s\n',fname);
load(fname);

% check for outlier bad channels & trials
% press !!! QUIT !!!
cfg                                 = [];
cfg.method                          = 'summary';
cfg.megscale                        = 1;
cfg.alim                            = 1e-12;
cfg.metric                          = 'maxabs';
InitRej                             = ft_rejectvisual(cfg,data_downsample);

% check for jumps % press !!! QUIT !!!
cfg                                 = [];
cfg.method                          = 'trial';
cfg.preproc.demean                  = 'yes';
cfg.megscale                        = 1;
% cfg.ylim                            = [-2e-12 2e-12];
% cfg.alim                            = cfg.ylim;
SecondRej                           = ft_rejectvisual(cfg,InitRej);
SecondRej                           = rmfield(SecondRej,'cfg');

% save trialinfo for re-creation purposes
trialinfo                           = SecondRej.trialinfo;
chaninfo                            = SecondRej.label;

fname                               = [dir_data subjectName '_' ext_lock '_preica_trialinfo.mat'];
fprintf('saving %s\n',fname);
save(fname,'trialinfo','chaninfo','-v7.3'); 
clear trialinfo chaninfo;

% save data
fname                               = [dir_data subjectName '_' ext_lock '_preica.mat'];
fprintf('saving %s\n',fname);
save(fname,'SecondRej','-v7.3');

a                                   = length(SecondRej.trialinfo);
b                                   = length(data_downsample.trialinfo);

fprintf('\ndone with %.2f trials remaining!\n',a/b);