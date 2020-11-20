function suj_list = who_what_per_subject(dir_file,ext_file)

suj_list                                = [1:33 35:36 38:44 46:51];
chk_nb                                  = [];

for ns = 1:length(suj_list)
    
    i                                   = 0;
    
    for nback = [0 1 2]
        for nlock = [0 1 2]
            
            list_file                   = dir(['../data/decode_data/' dir_file '/sub' num2str(suj_list(ns)) '.stim*.' ...
                num2str(nback) 'back.' num2str(nlock) 'lock.' ext_file '.mat']);
            
            i                           = i+1;
            chk_nb(ns,i)                = length(list_file);
            
        end
    end
    
    nm_test                             = i * 10; % 3 n-back condition .* 3 stimuli to lock to .* 10 stimuli in total
    
    i                                   = i+1;
    chk_nb(ns,i)                        = sum(chk_nb(ns,1:i-1));
    
    i                                   = i +1;
    chk_nb(ns,i)                        = suj_list(ns);
    
    
end

keep chk_nb nm_test;

suj_list                                = chk_nb(chk_nb(:,end-1) == nm_test,end); clear chk_nb;