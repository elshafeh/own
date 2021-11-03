clear;close all;

suj_list                                        = [1:33 35:36 38:44 46:51];

allperf                                         = [];
allrt                                           = [];
i                                               = 0;

dir_data_in                                     = '~/Dropbox/project_me/data/nback/behav_h/';
dir_data_out                                	= '~/github/own/doc/';

for nsuj = 1:length(suj_list)
    
    fname                                       = [dir_data_in 'sub' num2str(suj_list(nsuj)) '.behav.mat'];
    fprintf('loading %s\n',fname)
    load(fname);
    
    data_behav                                  = data_behav(data_behav(:,5) == 0 & data_behav(:,1) ~= 4,[1 6 7]);
    
    for nback = [5 6]
        
        data_sub                                = data_behav(data_behav(:,1) == nback,:);
        
        i = i+1;
        behav_struct(i).suj                     = ['sub' num2str(suj_list(nsuj))];
        behav_struct(i).cond                    = [num2str(nback-4) 'back'];
        
        % behavioural response (1=hit, 2=miss, 3=cr, 4=fa)
        lngth_trials_all                        = length(data_sub);
        lngth_trials_target                     = length(data_sub(data_sub(:,2) == 1 | data_sub(:,2) == 2));
        lngth_trials_notarget                   = length(data_sub(data_sub(:,2) == 3 | data_sub(:,2) == 4));
        
        allrt(nsuj,nback-4)                  	= median(data_sub(data_sub(:,3) > 0 & rem(data_sub(:,2),2) ~= 0,3)) / 1000;
        
        behav_struct(i).incorrect           	= length(data_sub(data_sub(:,2) == 2 | data_sub(:,2) == 4)) ./ lngth_trials_all;
        
        allperf(nsuj,nback-4)                   = behav_struct(i).incorrect .* 100;
        
    end
end

keep allperf allrt

%%

[h_perf,p_perf,ci_perf,stats_perf]    	= ttest(allperf(:,1),allperf(:,2));
[h_rt,p_rt,ci_rt,stats_rt]             	= ttest(allrt(:,1),allrt(:,2));