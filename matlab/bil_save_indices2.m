clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    
    if isunix
        subject_folder          = ['/project/3015079.01/data/' subjectName '/'];
    else
        subject_folder          = ['P:/3015079.01/data/' subjectName '/'];
    end
    
    name_in                     = '.cuelock.itc.comb.5binned.allchan';
    fname                       = [subject_folder 'tf/' subjectName name_in '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    bin_index                   = [];
    
    for nbin = 1:length(phase_lock)
        bin_index               = [bin_index phase_lock{nbin}.index];
    end
    
    fname_out                   = [subject_folder 'tf/' subjectName name_in '.index.mat'];
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'bin_index'); clear bin_index info fname_*;  
    
end