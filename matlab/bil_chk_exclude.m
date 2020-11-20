clear;

orig_name                                   = 'gratinglock_dwnsample100Hz';
suj_list                                    = dir(['../data/sub*/preproc/*' orig_name '.mat']);

for ns = 1:length(suj_list)
    
    subjectName                             = suj_list(ns).name(1:6);
    dir_data                                = ['../data/' subjectName '/preproc/'];
    
    fname                                   = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    %IMPORTANT!! -> exclude blocks with perfoamces either at chance
    % or celing
    data                                    = h_excludebehav(data,13,16);
    
end