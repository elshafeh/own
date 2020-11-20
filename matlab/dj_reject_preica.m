function dj_reject_preica

% check all -raw files

file_list                           = dir('../data/preproc/*.fixlock.raw.mat');
file_order                          = [];

for nf = 1:length(file_list)
    sub                             = strsplit(file_list(nf).name,'.');
    sub                             = sub{1};
    
    chk                             = dir(['../data/preproc/' sub '.fixlock.preica.mat']); 
    % check if this stip hasn't been done before
    if isempty(chk)
        list{nf}                    = sub;
        file_order                  = [file_order; nf];
    end
end

list                                = list(file_order);

% make a list for experimenter to choose from
[indx,~]                            = listdlg('ListString',list,'ListSize',[200,200]);

subjectName                         = list{indx};
dir_data                            = ['../data/preproc/'];

fname                               = ['../data/preproc/' subjectName '.fixlock.raw.mat'];
fprintf('Loading %s\n',fname);
load(fname);

% check for outlier bad channels & trials
cfg                                 = [];
cfg.method                          = 'summary';
cfg.megscale                        = 1;
cfg.alim                            = 1e-12;
cfg.metric                          = 'var';
InitRej                             = ft_rejectvisual(cfg,data);

% check for jumps % press !!! QUIT !!!
cfg                                 = [];
cfg.method                          = 'trial';

cfg.preproc.demean                  = 'yes';
cfg.megscale                        = 1;
cfg.alim                            = 2e-12;
data                                = ft_rejectvisual(cfg,InitRej);
% press !!! QUIT !!!
data                                = rmfield(data,'cfg');

% % save trialinfo for re-creation purposes
% % trialinfo                           = data.trialinfo;
% % chaninfo                            = data.label;
% % 
% % save data
% % fname                               = [dir_data subjectName '_firstRej_trialInfo.mat'];
% % save(fname,'trialinfo','chaninfo','-v7.3');
% % clear trialinfo chaninfo;

fname                               = [dir_data subjectName '.fixlock.preica.mat'];
fprintf('\nSaving %s\n',fname);
save(fname,'data','-v7.3');