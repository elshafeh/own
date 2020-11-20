clear ; clc;

if isunix
    project_dir             = '/project/3015079.01/';
else
    project_dir             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    
    fname                               = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);
    
    datainfo.grad                       = dataPostICA_clean.grad;
    datainfo.hdr                        = dataPostICA_clean.hdr;
    datainfo.elec                       = dataPostICA_clean.elec;
    datainfo.label                      = dataPostICA_clean.label;
    
    fname_out               = ['/project/3015039.06/bil/head/' subjectName '.datainfo.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'datainfo','-v7.3');
    
    keep nsuj suj_list project_dir 
    
end