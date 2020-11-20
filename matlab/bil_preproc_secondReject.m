function bil_preproc_secondReject
% final inspection of data using ft_rejectvisual in 'summary' mode
% and ft_databrowser

% check all -raw files
close all;clc;
file_list                           = dir('P:/3015079.01/data/sub*/preproc/*_firstCueLock_ICAlean.mat');
i                                   = 0;

for nf = 1:length(file_list)
    sub                             = file_list(nf).name(1:6);
    chk                             = dir(['P:/3015079.01/data/' sub '/preproc/*_firstCueLock_ICAlean_finalrej.mat']);
    % check if this stip hasn't been done before
    if isempty(chk)
        i                           = i +1;
        list{i}                     = sub;
    end
end

% make a list for experimenter to choose from
[indx,~]                            = listdlg('ListString',list,'ListSize',[200,200]);

subjectName                         = list{indx};
dir_data                            = ['P:/3015079.01/data/' subjectName '/preproc/'];

fname                               = [dir_data subjectName '_firstCueLock_ICAlean.mat'];
fprintf('Loading %s\n',fname);
load(fname);

cfg                                 = [];
cfg.method                          = 'summary';
cfg.metric                          = 'var';
cfg.megscale                        = 1;
cfg.alim                            = 1e-12;
postICA_Rej                         = ft_rejectvisual(cfg,dataPostICA);

%

cfg                                 = [];
cfg.channel                         = 'MEG';
RejCfg                              = ft_databrowser(cfg,postICA_Rej);

dataPostICA_clean                   = ft_rejectartifact(RejCfg,postICA_Rej);

dataPostICA_clean                   = rmfield(dataPostICA_clean,'cfg');
fname                               = [dir_data subjectName '_firstCueLock_ICAlean_finalrej.mat'];
fprintf('Saving %s\n',fname);
save(fname,'dataPostICA_clean','-v7.3');

index                               = dataPostICA_clean.trialinfo;
fname                               = [dir_data subjectName '_firstCueLock_ICAlean_finalrej_trialinfo.mat'];
fprintf('Saving %s\n',fname);
save(fname,'index');

fprintf('\ndone \n');

h_bil_clean(subjectName);