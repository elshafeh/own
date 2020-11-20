clear;clc;

if ispc
    start_dir = 'P:\';
else
    start_dir = '/project/';
end

prpc    = length(dir([start_dir '3015079.01/data/sub0*/preproc/*_firstCueLock_ICAlean_finalrej.mat']));
nw      = length(dir([start_dir '3015079.01/raw/sub0*.ds']));

disp('%%%%%%%%%')
disp('%% BIL %%')
disp('%%%%%%%%%')

disp([num2str(nw) ' subjects in total'])
disp([num2str(prpc) ' preprocessed'])

%%

fprintf('\n');
disp('%%%%%%%%%')
disp('%% ADE %%')
disp('%%%%%%%%%')

list_mod    = {'aud','vis'};

for nmod = 1:length(list_mod)
    fprintf('~~ %3s ~~\n',list_mod{nmod})
    fprintf('%2d subjects in total\n',length(dir([start_dir '3015039.04/raw/sub-*/ses*' list_mod{nmod}])));
    fprintf('%2d preprocessed\n',length(dir([start_dir '3015039.04/data/*/preprocessed/*_secondreject_postica_' list_mod{nmod} '.mat'])));
    fprintf('\n');
end

%%

fprintf('\n');

disp('%%%%%%%%%%')
disp('%% EYES %%')
disp('%%%%%%%%%%')

fprintf('%2d subjects in total\n',length(dir([start_dir '3015039.05/raw/*ds'])));
fprintf('%2d preprocessed\n',length(dir([start_dir '3015039.05/data/*/preproc/*_stimLock_ICAlean_finalrej.mat'])));
fprintf('\n');
