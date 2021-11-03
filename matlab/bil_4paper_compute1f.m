clear; clc;
close all;

if isunix
    project_dir     	= '/project/3015079.01/data/';
else
    project_dir     	= 'P:/3015079.01/data/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    subjectName       	= suj_list{ns};
    
    fname           	= [project_dir subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname           	= [project_dir subjectName '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    
end