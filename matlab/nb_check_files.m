clear;clc;

for nsuj = [1:33 35:36 38:44 46:51]
   
    list_decoding = {'condition' 'first' 'target' 'stim*'};
    
    for ndeco = 1:length(list_decoding)
       
        dir_files   = 'P:/3035002.01/nback/auc/';
        fname       = ['sub' num2str(nsuj) '.decoding.' list_decoding{ndeco} '.nodemean.leaveone.mat'];
        flist       = dir([dir_files fname]);
    
        if isempty(flist)
            warning([fname ' does not exist'])
        else
            disp(['found ' num2str(length(flist)) ' files']);
        end
        
    end
end