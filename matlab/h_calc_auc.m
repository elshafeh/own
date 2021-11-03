function AUC_bin_test = h_calc_auc(y_array,yproba_array,idx_trials)

AUC_bin_test                = [];

for ntime = 1:size(y_array,2)
    
    yproba_array_test     	= yproba_array(idx_trials,ntime);
    
    if min(unique(y_array(:,ntime))) == 1
        yarray_test        	= y_array(idx_trials,ntime) - 1;
    else
        yarray_test       	= y_array(idx_trials,ntime);
    end
    
    [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
    
end