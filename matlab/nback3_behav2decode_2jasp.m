clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_files            	= '~/Dropbox/project_me/data/nback/';
    ext_decode          	= 'stim';
    
    list_stim               = [2 3 4 5 7 8 9]; % [1 2 3 4 5 6 7 8 9]; %
    
    for nstim = 1:length(list_stim)
        
        % load decoding output
        dir_files          	= '~/Dropbox/project_me/data/nback/';
        fname            	= [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname); %,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array            	= y_array';
        yproba_array      	= yproba_array';
        e_array          	= e_array';
        yhat_array          = yhat_array';
        
        measure           	= 'yproba'; % auc yproba
        
        fname             	= [dir_files 'trialinfo/' sujname '.flowinfo.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        sub_info         	= trialinfo(:,[4 5 6]);
        sub_info_correct 	= sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
        sub_info_correct 	= sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
        median_rt         	= median(sub_info_correct(:,2));
        
        index_trials{1}  	= sub_info_correct(sub_info_correct(:,2) < median_rt,3); % fast
        index_trials{2}  	= sub_info_correct(sub_info_correct(:,2) > median_rt,3); % slow
        
        for nbin = [1 2]
            
            idx_trials                      = index_trials{nbin};
            
            AUC_bin_test                 	= [];
            disp('computing AUC');
            
            for ntime = 1:size(y_array,2)
                
                if strcmp(measure,'yproba')
                    
                    yproba_array_test     	= yproba_array(idx_trials,ntime);
                    
                    if min(unique(y_array(:,ntime))) == 1
                        yarray_test        	= y_array(idx_trials,ntime) - 1;
                    else
                        yarray_test       	= y_array(idx_trials,ntime);
                    end
                    
                    try 
                        [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                    catch
                        AUC_bin_test(ntime)         = NaN;
                    end
                        
                elseif strcmp(measure,'auc')
                    AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
                elseif strcmp(measure,'confidence')
                    AUC_bin_test(ntime)     = mean(yhat_array(idx_trials,ntime));
                end
            end
            
            avg                             = [];
            avg.avg                         = AUC_bin_test;
            avg.time                        = time_axis;
            avg.label                       = {['decoding ' ext_decode]};
            avg.dimord                      = 'chan_time';
            
            alldata{nsuj,nbin,nstim}        = avg; clear avg;
            
        end
    end
    
end

%%

keep alldata list_* ext_decode

for nsuj = 1:size(alldata,1)
    for nbin = 1:size(alldata,2)
        
        tmp         = [];
        i           = 0;
        
        for nstim = 1:size(alldata,3)
            if ~isempty(alldata{nsuj,nbin,nstim})
                tmp     = [tmp; alldata{nsuj,nbin,nstim}.avg];
                i       = nstim;
            end
        end
        
        newdata{nsuj,nbin}        = alldata{nsuj,nbin,1};
        newdata{nsuj,nbin}.avg    = nanmean(tmp,1); clear tmp;
        
        
        clear tmp;
        
    end
end

alldata                         = newdata;

%%

keep alldata

data_out                        = {};
data_label                      = {};

for nsuj = 1:size(alldata,1)
    
    icol                        = 0;
    
    for nbin = 1:size(alldata,2)
        
        time_width              = 0.09;
        time_point              = [-0.1 0 0.1 0.2 0.3 0.4 0.5 0.6];
        
        for ntime = 1:length(time_point)
            
            icol                = icol+1;
            
            t1                  = nearest(alldata{nsuj,nbin}.time,time_point(ntime));
            t2                  = nearest(alldata{nsuj,nbin}.time,time_point(ntime)+time_width);
            
            data_label{icol}    = ['b' num2str(nbin) '_t' num2str(ntime)];
            data_out{nsuj,icol} = mean(alldata{nsuj,nbin}.avg(1,t1:t2));
            
            
            
        end
    end
end

keep *data*

DataTable                       = array2table(data_out,'VariableNames',data_label);
writetable(DataTable,'../doc/nback_behav2decode_stim.csv')
