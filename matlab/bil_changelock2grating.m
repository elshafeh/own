clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 14:length(suj_list)
    
    subjectName                         = suj_list{ns};
    
    if isunix
        subject_folder = ['/project/3015079.01/data/' subjectName '/preproc/'];
    else
        subject_folder = ['P:/3015079.01/data/' subjectName '/preproc/'];
    end
    
    data                                = bil_changelock_onlytarget(subjectName,[5 2]);
    %     data                                = bil_changelock_onlyprobe(subjectName);
    
    cfg                                 = [];
    cfg.resamplefs                      = 70;
    cfg.detrend                         = 'no';
    cfg.demean                          = 'no';
    data                                = ft_resampledata(cfg, data);
    data                                = rmfield(data,'cfg');
    
    list_name                           = 'secondgab.lock';
    
    fname                               = [subject_folder subjectName '.' list_name '.dwnsample' num2str(cfg.resamplefs) 'Hz.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'data','-v7.3');toc;
    
    index                               = data.trialinfo;
    fname                               = [subject_folder subjectName '.' list_name '.trialinfo.mat'];
    fprintf('Saving %s\n',fname);
    tic;save(fname,'index');toc;
    
end