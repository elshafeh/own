function taco_preproc_ica_compute

% compute and save ica decomposition

lock_list                               = {'firstcuelock' 'localizerlock'};
[indx,~]                                = listdlg('ListString',lock_list,'ListSize',[100,100]);
ext_lock                                = lock_list{indx};

if ispc
    start_dir = 'D:/Dropbox/project_me/data/taco/';
else
    start_dir = '~/Dropbox/project_me/data/taco/';
end

suj_list                                = dir([start_dir 'preproc/*' ext_lock '_raw_dwnsample.mat']);

for ns = 1:length(suj_list)
    
    name_ext.input                      = ['_' ext_lock '_preica.mat'];
    name_ext.intermediate               = ['_' ext_lock '_ica_started.mat'];
    name_ext.output                     = ['_' ext_lock '_icacomponents.mat'];
    name_ext.final                      = ['_' ext_lock '_icalean_finalrej.mat'];
    
    
    % check this hasn;t been done before
    subjectName                         = suj_list(ns).name(1:6);
    chk1                               	= dir([start_dir 'preproc/' subjectName '*' name_ext.output]);
    chk2                                = dir([start_dir 'preproc/' subjectName '*' name_ext.final]);
    chk3                                = dir([start_dir 'preproc/' subjectName '*' name_ext.intermediate]);

    if isempty(chk1) && isempty(chk2) && isempty(chk3)
        
        dir_data                        = [start_dir 'preproc/'];
        
        x                               = [];
        fname                           = [dir_data subjectName name_ext.intermediate];
        fprintf('Saving %s\n',fname);
        save(fname,'x');
        
        fname                           = [dir_data subjectName name_ext.input];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        cfg                             = [];
        cfg.method                      = 'runica';
        comp                            = ft_componentanalysis(cfg,SecondRej);
        
        fname                           = [dir_data subjectName name_ext.output];
        fprintf('Saving %s\n',fname);
        save(fname,'comp','-v7.3');
        
    end
end