function bil_preproc_ica_compute

% compute and save ica decomposition

if ispc
    start_dir = 'P:\';
else
    start_dir = '/project/';
end

suj_list                                = dir([start_dir '3015079.01/data/sub*/preproc/*_firstCueLock_preICA.mat']);

for ns = 1:length(suj_list)
    
    % check this hasn;t been done before
    subjectName                         = suj_list(ns).name(1:6);
    chk1                               	= dir([start_dir '3015079.01/data' subjectName '/preproc/*_firstCueLock_ICAcomp.mat']);
    chk2                                = dir([start_dir '3015079.01/data/' subjectName '/preproc/*_firstCueLock_ICAlean_finalrej.mat']);
    chk3                                = dir([start_dir '3015079.01/data/' subjectName '/preproc/*.ica.started.mat']);

    if isempty(chk1) && isempty(chk2) && isempty(chk3)
        
        dir_data                        = [start_dir '3015079.01/data/' subjectName '/preproc/'];
        
        x                               = [];
        fname                           = [dir_data subjectName '.ica.started.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'x');
        
        fname                           = [dir_data subjectName '_firstCueLock_preICA.mat'];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        cfg                             = [];
        cfg.method                      = 'runica';
        comp                            = ft_componentanalysis(cfg,SecondRej);
        
        fname                           = [dir_data subjectName '_firstCueLock_ICAcomp.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'comp','-v7.3');
        
    end
end