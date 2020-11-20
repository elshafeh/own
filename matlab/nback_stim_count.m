clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

stim_count                          = zeros(length(suj_list),3);

for nsuj = 1:length(suj_list)
    for nback = [0 1 2]
        
        pow                         = nan(10,210);
        
        for nstim = 1:10
            
            file_list                   = dir(['K:\nback\stim_per_cond\sub' num2str(suj_list(nsuj)) '.sess*.stim' ...
                num2str(nstim) '.' num2str(nback) 'back.dwn70.auc.mat']);            
            
            stim_count(nsuj,nback+1)    = stim_count(nsuj,nback+1) + length(file_list);
            
        end
    end
end

keep stim_count