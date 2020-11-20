clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    file_list               = {'.resplock.dwnsample100Hz.mat' '.secondgab.lock.dwnsample70Hz.mat' '.firstgab.lock.dwnsample70Hz.mat'};
    
end