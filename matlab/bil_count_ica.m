clear ; clc; close all;

if isunix
    project_dir       	= '/project/3015079.01/';
else
    project_dir      	= 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName        	= suj_list{nsuj};
    fname              	= [project_dir 'data/' subjectName '/preproc/' subjectName '_ica_rej_comp.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    nb_comp(nsuj)       = length(cfg.component);
    
end

keep nb_comp ; clc;

fprintf('%.2f components on average\n',mean(nb_comp));