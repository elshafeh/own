clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                   	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    suj_name                = ['sub' num2str(suj_list(nsuj))];
    
    for nback = [0 1 2]
        
        fname                   = ['I:\nback\tf\' suj_name '.' num2str(nback) 'back.1t100Hz.1HzStep.KeepTrials.nonfill.rearranged.mat'];
        fprintf('loading %s\n',fname);
        load(fname); clear fname;
        
        freq_comb               = ft_freqdescriptives([],freq_comb); 
        freq_comb               = rmfield(freq_comb,'cfg');
        
        fname_out               = ['P:/3015039.06/hesham/nback/tf/' suj_name '.' num2str(nback) 'back.1t100Hz.1HzStep.avgTrials.nonfill.rearranged.mat'];
        fprintf('Saving %s\n',fname_out);
        tic;save(fname_out,'freq_comb','-v7.3');toc;
        
    end
end