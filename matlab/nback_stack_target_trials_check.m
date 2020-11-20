clear;close all;

suj_list                   	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    suj_name                = ['sub' num2str(suj_list(nsuj))];
    
    for nback = [0 1 2]
        
        fname           	= ['I:\nback\preproc\' suj_name '.' num2str(nback) 'back.rearranged.trialinfo.mat'];
        fprintf('loading %s\n',fname);
        load(fname); clear fname;
        
        trl_indx{1}         = find(index(:,3) == 1);
        trl_indx{2}         = find(index(:,3) == 0);
        
        if (length(trl_indx{1}) + length(trl_indx{2})) ~= length(index)
            error('something wrong!')
        end
        
    end
    
end