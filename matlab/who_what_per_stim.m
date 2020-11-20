function stim_list = who_what_per_stim(dir_file,ext_file)

suj_list                                = [1:33 35:36 38:44 46:51];
chk_nb                                  = [];

for nstim = 1:10
    
    i                                   = 0;
    
    for nback = [0 1 2]
        for nlock = [0 1 2]
            
            list_file                   = dir(['../data/decode_data/' dir_file '/sub*.stim' num2str(nstim) '.' ...
                num2str(nback) 'back.' num2str(nlock) 'lock.' ext_file '.mat']);
            
            i                           = i+1;
            chk_nb(nstim,i)             = length(list_file);
            
        end
    end
    
    nm_test                             = i * length(suj_list); % 3 n-back condition .* 3 stimuli to lock to .* number of subjects in total
    
    i                                   = i+1;
    chk_nb(nstim,i)                     = sum(chk_nb(nstim,1:i-1));
    
    i                                   = i +1;
    chk_nb(nstim,i)                     = nstim;
    
    
end

keep chk_nb nm_test;

stim_list                               = chk_nb(chk_nb(:,end-1) == nm_test,end); clear chk_nb;