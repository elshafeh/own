function [data,time_axis] = h_auc(sujname,list_stim,idx_trials)

data                = [];

for nstim = 1:length(list_stim)
    
    % load decoding output
    dir_files          	= '~/Dropbox/project_me/data/nback/';
    fname            	= [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % transpose matrices
    y_array           	= y_array';
    yproba_array       	= yproba_array';
    
    e_array          	= e_array';
    auc_array           = auc_array';
    
    
    AUC_bin_test    = [];
    
    for ntime = 1:size(y_array,2)
        
        yproba_array_test     	= yproba_array(idx_trials,ntime);
        
        if min(unique(y_array(:,ntime))) == 1
            yarray_test        	= y_array(idx_trials,ntime) - 1;
        else
            yarray_test       	= y_array(idx_trials,ntime);
        end
        
        try
            [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
        catch
            AUC_bin_test(ntime) = NaN;
        end
        
        clear yarray_test yproba_array_test
        
    end
    
    data(nstim,:)        = AUC_bin_test;clear AUC_bin_test;
    
    
end

data                    = mean(data,1);