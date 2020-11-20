clear;

% to remove raw -mat (not .ds) data

file_list       = dir('../data/s*/preproc/*_firstcuelock_raw_dwnsample.mat');

for nf = 1:length(file_list)
    
    fname       = [file_list(nf).folder filesep file_list(nf).name];
    fprintf('removing %s\n',fname);
    system(['rm ' fname]);
    
end