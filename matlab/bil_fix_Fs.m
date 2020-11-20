clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for lock_ext                               = {'1stcue','1stgab','2ndgab','response'}
    for nsuj = 6:length(suj_list)
        
        subjectName                     = suj_list{nsuj};
        
        flist                           = dir(['F:/bil/preproc/' subjectName '.' lock_ext{:} '.*ed.mat']);
        
        for nf = 1:length(flist)
            
            fname                      	= [flist(nf).folder filesep flist(nf).name];
            fprintf('\nloading %s\n',fname);
            load(fname);
            
            if isfield(data,'Fs')
                data                    = rmfield(data,'Fs');
            end
            
            if isfield(data,'elec')
                data                    = rmfield(data,'elec');
            end
            
            if isfield(data,'grad')
                data                    = rmfield(data,'grad');
            end
            
            data.fsample              	= 1/0.05;
            
            fprintf('Saving %s\n',fname);
            tic;save(fname,'data','-v7.3');toc; clear data;
            
        end
        
        
    end
    
end