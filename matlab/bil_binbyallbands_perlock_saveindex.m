clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

if isunix
    project_dir             = '/project/3015079.01/';
    start_dir               = '/project/';
else
    project_dir             = 'P:/3015079.01/';
    start_dir               = 'P:/';
end

keep suj_list allpeaks ; clc;

i                           = 0;

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    if isunix
        subject_folder      = ['/project/3015079.01/data/' subjectName '/'];
    else
        subject_folder      = ['P:/3015079.01/data/' subjectName '/'];
    end
    
    list_lock               = {'1stcue' '2ndcue'};
    list_band               = {'theta' 'alpha' 'beta'};
    
    for nlock = 1:length(list_lock)
        for nband = 1:length(list_band)
            
            fname_in     	= [subject_folder 'tf/' subjectName '.' list_lock{nlock} '.lock.allbandbinning.' ...
                list_band{nband} '.band.prestim.window.mat'];
            fprintf('load %s\n',fname_in);
            load(fname_in,'bin_summary');
            
            bin_index       = bin_summary.bins;
            
            fname_out     	= [subject_folder 'tf/' subjectName '.' list_lock{nlock} '.lock.allbandbinning.' ...
                list_band{nband} '.band.prestim.window.index.mat'];
            fprintf('save %s\n',fname_out);
            save(fname_out,'bin_index');
            
        end
    end
end