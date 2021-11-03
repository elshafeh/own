clear;close all;clc;

suj_list                      	= [1:33 35:36 38:44 46:51];
alldata                         = [];

for nsuj = 1:length(suj_list)
    
    dir_data_in               	= '~/Dropbox/project_me/data/nback/behav_h/';
    fname                     	= [dir_data_in 'sub' num2str(suj_list(nsuj)) '.behav.mat'];
    fprintf('loading %s\n',fname)
    load(fname);
    
    data_sub                   	= data_behav(data_behav(:,1) ~= 4 & data_behav(:,3) == 2,[1 6 7]);

    % behavioural response (1=hit, 2=miss, 3=cr, 4=fa)
    lngth_trials_all         	= length(data_sub);
    
    perc_incorrect           	= length(data_sub(data_sub(:,2) == 2 | data_sub(:,2) == 4)) ./ lngth_trials_all;
    perc_incorrect            	= perc_incorrect * 100;
    vector_rt                 	= data_sub(data_sub(:,2) == 1 | data_sub(:,2) == 3,3) ./ 1000;
    vector_rt(vector_rt == 0) 	= NaN;
    median_rt                   = nanmedian(vector_rt);
    
    alldata                  	= [alldata;perc_incorrect median_rt];
    
    keep alldata nsuj suj_list 
    
end

%%

keep alldata

% behav_table                     = array2table(alldata,'VariableNames',{'p incorrect' 'rt'});
% writetable(behav_table,'../doc/nback_behav_correlate.csv');

[R,PValue]                      = corrplot(alldata,'varNames',{'p incorrect' 'rt'},'Type','Spearman','testR','on');
