clear ; close all;

if isunix
    project_dir              	= '/project/3015079.01/';
    start_dir                	= '/project/';
else
    project_dir              	= 'P:/3015079.01/';
    start_dir               	= 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName               	= suj_list{nsuj};    
    list_bin                	= {'bin1' 'bin5'};
    
    for nbin = 1:length(list_bin)
        
        fname_in               	= [project_dir 'data/' subjectName '/erf/' subjectName '.cuelock.itc.withcorrect.' list_bin{nbin} '.erf.mat'];
        fname_out            	= ['D:/Dropbox/project_me/papers/postdoc/bilbo/v1/data/erf/' subjectName '.cuelock.itc.withcorrect.' list_bin{nbin} '.erf.mat'];
        
        fprintf('copying %s\n',fname_in);       
        copyfile(fname_in,fname_out);
        
    end
end