clear;clc;

suj_list                           	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                      	= ['sub' num2str(suj_list(nsuj))];
    
    dir_files                    	= 'P:/3035002.01/nback/';
    
    list_decode                   	= 'condition'; % target first condition
    
    % load decoding output
    fname                           = [dir_files 'auc/' sujname '.decoding.' list_decode '.nodemean.leaveone.mat'];
    fprintf('loading %s\n',fname);
    load(fname,'y_array','yproba_array','time_axis','e_array');
    
    % transpose matrices
    y_array                     	= y_array';
    yproba_array                  	= yproba_array';
    e_array                       	= e_array';
    
    t1                              = nearest(time_axis,0.1);
    t2                              = nearest(time_axis,0.3);
    
    e_vector                        = mean(e_array(:,t1:t2),2);
    e_avg                           = median(e_vector);
    
    index_trials{1}              	= find(e_vector > e_avg);
    index_trials{2}             	= find(e_vector < e_avg);
    
    for nbin = [1 2]
        
        idx_trials              	= index_trials{nbin};
        
        AUC_bin_test             	= [];
        disp('computing AUC');
        
        for ntime = 1:size(y_array,2)
            
            yproba_array_test     	= yproba_array(idx_trials,ntime);
            
            if min(unique(y_array(:,ntime))) == 1
                yarray_test        	= y_array(idx_trials,ntime) - 1;
            else
                yarray_test       	= y_array(idx_trials,ntime);
            end
            
            [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
            
            
        end
        
        avg                             = [];
        avg.avg                         = AUC_bin_test;
        avg.time                        = time_axis;
        avg.label                       = {['decoding ' list_decode]};
        avg.dimord                      = 'chan_time';
        
        alldata{nsuj,nbin}              = avg; clear avg;
        
    end
    
end

keep alldata

%%

