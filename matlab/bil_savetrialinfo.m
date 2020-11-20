clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    
    fname                               = ['~/Dropbox/project_me/data/bil/virt/' subjectName '.virtualelectrode.wallis.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    index                               = data.trialinfo;
    
    fname                               = ['~/Dropbox/project_me/data/bil/virt/' subjectName '.virtualelectrode.wallis.index.mat'];
    fprintf('saving %s\n',fname);
    save(fname,'index');
    
end