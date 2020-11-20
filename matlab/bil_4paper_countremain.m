clear ; clc;

if isunix
    project_dir                 = '/project/3015079.01/';
    start_dir                   = '/project/';
else
    project_dir                 = 'P:/3015079.01/';
    start_dir                   = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    fname                       = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej_trialinfo.mat'];
    load(fname);
    
    trial_remain(nsuj,1)     	= length(index);
    
end

keep trial_remain

mean_remain                     = mean(trial_remain);
sem_remain                      = std(trial_remain, [], 1) ./ sqrt(size(trial_remain,1));