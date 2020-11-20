function dj_reject_postica

% check all -raw files
close all;clc;
file_list                           = dir('../data/preproc/*.fixlock.ica.clean.mat');
i                                   = 0;

for nf = 1:length(file_list)
    
    subjectName                     = strsplit(file_list(nf).name,'.');
    subjectName                     = subjectName{1};
    chk                             = dir(['../data/preproc/' subjectName '.fixlock.fin.mat']);
    % check if this stip hasn't been done before
    if isempty(chk)
        i                           = i +1;
        list{i}                     = subjectName;
    end
end

% make a list for experimenter to choose from
[indx,~]                            = listdlg('ListString',list,'ListSize',[200,200]);

subjectName                         = list{indx};
dir_data                            = '../data/preproc/';

fname                               = [dir_data subjectName '.fixlock.ica.clean.mat'];
fprintf('Loading %s\n',fname);
load(fname);

cfg                                 = [];
cfg.method                          = 'summary';
cfg.metric                          = 'var';
cfg.megscale                        = 1;
cfg.alim                            = 1e-12;
data                                = ft_rejectvisual(cfg,data);

%

cfg                                 = [];
cfg.channel                         = 'MEG';
RejCfg                              = ft_databrowser(cfg,data);

data                                = ft_rejectartifact(RejCfg,data);
data                                = rmfield(data,'cfg');

fname                               = [dir_data subjectName '.fixlock.fin.mat'];
fprintf('Saving %s\n',fname);
save(fname,'data','-v7.3');

% index                               = data.trialinfo;
% fname                               = [dir_data subjectName '_firstCueLock_ICAlean_finalrej_trialinfo.mat'];
% fprintf('Saving %s\n',fname);
% save(fname,'index');
% 
% fprintf('\ndone \n');
% 
% h_bil_clean(subjectName);