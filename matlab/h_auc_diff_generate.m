function [data , time_axis] = h_auc_diff_generate(sujname,list_stim,flg_trials)

data                    = [];
bad_trials              = [];
bad_stim                = [];

for nstim = 1:length(list_stim)
    
    % load decoding output
    try
        
        dir_files   	= '~/Dropbox/project_me/data/nback/';
        fname        	= [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis');
        
        % transpose matrices
        y_array      	= y_array';
        yproba_array  	= yproba_array';
        
        y_array        	= y_array(flg_trials,:);
        yproba_array   	= yproba_array(flg_trials,:);
        
        auc_all        	= h_calc_auc(y_array,yproba_array,1:size(y_array,1));
        auc_diff      	= [];
        
        for ntrial = 1:size(y_array,1)
            
            disp([sujname ' Stim' num2str(list_stim(nstim)) ': trial ' num2str(ntrial) ' / ' num2str(size(y_array,1))]);
            
            index_trials        = 1:size(y_array,1);
            index_trials(index_trials == ntrial) = [];
            
            try
                tmp_auc             = h_calc_auc(y_array,yproba_array,index_trials);
                tmp_diff            = auc_all - tmp_auc;
                auc_diff(ntrial,:)  = tmp_diff;
            catch
                warning('trial will be excluded');
                auc_diff(ntrial,:)  = nan(1,length(time_axis));
                bad_trials          = [bad_trials;ntrial];
            end
            
            clear tmp_diff tmp_auc
            
        end
        
        data          	= cat(3,data,auc_diff);
        
    catch
        warning('stim will be excluded');
        bad_stim        = [bad_stim;nstim];
    end
    
end

% remove bad trials
bad_trials              = unique(bad_trials);
data(bad_trials,:,:)	= [];

% remove bad stim
if bad_stim <= size(data,3)
    data(:,:,bad_stim)	= [];
end

data                    = nanmean(data,3);