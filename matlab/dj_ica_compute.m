function dj_ica_compute

suj_list                            = dir('../data/preproc/*.fixlock.preica.mat');

for ns = 1:length(suj_list)
    
    % check this hasn;t been done before
    subjectName                     = strsplit(suj_list(ns).name,'.');
    subjectName                     = subjectName{1};
    
    dir_data                        = '../data/preproc/';
    fname                           = [dir_data subjectName '.fixlock.preica.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    cfg                             = [];
    cfg.method                      = 'runica';
    comp                            = ft_componentanalysis(cfg,data);
    
    fname                           = [dir_data subjectName '.fixlock.icacomp.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'comp','-v7.3');
    
end