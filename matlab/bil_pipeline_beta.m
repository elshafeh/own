clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 23:length(suj_list)
    
    if isunix
        subject_folder      = ['/project/3015079.01/data/' subjectName '/'];
    else
        subject_folder      = ['P:/3015079.01/data/' subjectName '/'];
    end
    
    subjectName             = suj_list{nsuj};
    freq                    = bil_beta_mtm_compute(subjectName);
    bil_beta_findpeak(subjectName,freq);
    
end