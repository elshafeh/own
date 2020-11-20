clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName          	= suj_list{nsuj};
    
    %     dir_in                  = 'I:/bil/head/';
    %     dir_out                 = ['P:/3015079.01/data/' subjectName '/head/'];
    %     flist                   = dir([dir_in  subjectName '.volgridLead.0.5cm.withNas.mat']);
    
    %     dir_in                  = 'I:/bil/mri/';
    %     dir_out                 = ['P:/3015079.01/data/' subjectName '/mri/'];
    %     flist                   = dir([dir_in  subjectName '.processedmri.plusnas.mat']);
    
    dir_in                  = 'I:/bil/tf/';
    dir_out                 = ['P:/3015079.01/data/' subjectName '/tf/'];
    flist                   = dir([dir_in  subjectName '*.AvgTrials.*']);
    
    for nfile = 1:length(flist)
        
        fname_in            = [dir_in flist(nfile).name];
        fname_out        	= [dir_out flist(nfile).name];
        
        if ~exist(fname_out)
            fprintf('source: %s\n',fname_in);
            fprintf('destination: %s\n\n',fname_out);
            tic;movefile(fname_in,fname_out);toc; clear fname_*
        else
            win_rm(fname_in);
        end
        
    end
    
end