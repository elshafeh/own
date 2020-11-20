clear;clc;

suj_list        = dir('../rawdata/') ;

for n = 1:length(suj_list)
    if length(suj_list(n).name) > 2 && length(suj_list(n).name) < 5
        
        suj             = suj_list(n).name;
        direc_suj       = ['../data/' suj '/'];
        
        if ~exist(direc_suj)
            
            mkdir([direc_suj 'ds']);
            mkdir([direc_suj 'meeg/']);
            mkdir([direc_suj 'meeg/single/']);
            mkdir([direc_suj 'res/']);
            mkdir([direc_suj 'pos/']);
            mkdir([direc_suj 'behav/']);
            mkdir([direc_suj 'mri/']);
            
        end
    end
end