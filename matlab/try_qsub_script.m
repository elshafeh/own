clear;

addpath /home/common/matlab/fieldtrip/qsub/

n_array         = {'sub3' 'sub4'};
time_per_sub    = 10; % in hours

qsubcellfun(@try_qsub_function, n_array, 'memreq', 67645734912, 'timreq', time_per_sub*60*60, 'stack', 1);

