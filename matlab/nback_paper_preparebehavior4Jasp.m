clear;close all;

suj_list                                        = [1:33 35:36 38:44 46:51];

dir_data_in                                     = 'D:/Dropbox/project_me/data/nback/behav_h/';
dir_data_out                                	= 'M:/github/me/data/txt/';

for nsuj = 1:length(suj_list)
    
    fname                                       = [dir_data_in 'sub' num2str(suj_list(nsuj)) '.behav.mat'];
    fprintf('loading %s\n',fname)
    load(fname);
    
    data_behav                                  = data_behav(:,[1 6 7]);
    
    i                                       	= 1;
    alldata{nsuj,i}                             = ['sub' num2str(suj_list(nsuj))];
    list_var{i}                                 = 'sub';
    
    for nback = [5 6]
        
        data_sub                                = data_behav(data_behav(:,1) == nback,:);
        
        % behavioural response (1=hit, 2=miss, 3=cr, 4=fa)
        lngth_trials_all                        = length(data_sub);
        
        i = i +1;
        list_var{i}                             = ['rt_B' num2str(nback-4)];
        crct_trials                             = data_sub(data_sub(:,2) == 1 | data_sub(:,2) == 3,:);
        alldata{nsuj,i}                      	= median(crct_trials(crct_trials(:,3) > 0,3));
        
        i = i +1;
        list_var{i}                             = ['inc_B' num2str(nback-4)];
        alldata{nsuj,i}                      	= length(data_sub(data_sub(:,2) == 2 | data_sub(:,2) == 4)) ./ lngth_trials_all;
        
        
    end
    
    keep nsuj alldata list_var suj_list dir_data*
    
end

keep alldata list_var dir_data*

behav_table                                     = cell2table(alldata,'VariableNames',list_var);

writetable(behav_table,[dir_data_out 'nback_behav_data_4jasp_adjust.csv']);