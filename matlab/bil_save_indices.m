clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    
    if isunix
        subject_folder          = ['/project/3015079.01/data/' subjectName '/'];
    else
        subject_folder          = ['P:/3015079.01/data/' subjectName '/'];
    end
    
    ext_index                   = 'retrocuelock';
    fname                       = [subject_folder 'tf/' subjectName '.' ext_index '.itc.5binned.withEvoked.withIncorrect.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    bin_index                   = [];
    
    for nbin = 1:length(phase_lock)
        bin_index               = [bin_index phase_lock{nbin}.index];
    end
    
    fname_out                   = [subject_folder 'tf/' subjectName '.' ext_index '.itc.incorrect.index.mat'];
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'bin_index'); clear bin_index info fname_*;
    
    %     for freq = {'theta' 'alpha' 'beta' 'gamma'}
    %         for window = {'preCue1' 'preCue2' 'preGab1' 'preGab2'}
    %
    %             fname_in            = [subject_folder 'tf/' subjectName '.allbandbinning.' freq{:} '.band.' window{:} '.window.mat'];
    %             fprintf('loading %s\n',fname_in);
    %             load(fname_in);
    %
    %             bin_index           = info.bin_summary.bins;
    %
    %             fname_out           = [subject_folder 'tf/' subjectName '.allbandbinning.' freq{:} '.band.' window{:} '.window.index.mat'];
    %             fprintf('saving %s\n',fname_out);
    %             save(fname_out,'bin_index'); clear bin_index info fname_*;
    %
    %         end
    %     end
    
end