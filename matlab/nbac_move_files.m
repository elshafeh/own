clear;clc;

suj_list    = [1:33 35:36 38:44 46:51];
freq_list   = [6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28];

for nsuj = suj_list
    for nses = 1:2
        for nfreq = freq_list
            
            f_in    = ['J:/temp/nback/data/tf/sub' num2str(nsuj) '.sess' num2str(nses) '.orig.' num2str(nfreq) 'Hz.mat'];
            f_out   = ['P:/3015039.05/nback/tf/sub' num2str(nsuj) '.sess' num2str(nses) '.orig.' num2str(nfreq) 'Hz.mat'];
            
            if ~exist(f_out)
                fprintf('copying %s\n',f_in);
                copyfile(f_in,f_out);
            end
            
            clear f_in f_out
            
        end
    end
end