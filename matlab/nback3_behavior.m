clear;close all;

suj_list                                        = [1:33 35:36 38:44 46:51];
suj_list(suj_list == 19)                        = [];
suj_list(suj_list == 38)                        = [];

allperf                                         = [];
allrt                                           = [];
i                                               = 0;

dir_data_in                                     = '~/Dropbox/project_me/data/nback/behav_h/';
dir_data_out                                	= '~/github/own/doc/';

for ns = 1:length(suj_list)
    
    fname                                       = [dir_data_in 'sub' num2str(suj_list(ns)) '.behav.mat'];
    fprintf('loading %s\n',fname)
    load(fname);
    
    data_behav                                  = data_behav(data_behav(:,5) == 0 & data_behav(:,1) ~= 4,[1 6 7]);
    %     data_behav                                  = data_behav(data_behav(:,1) ~= 4,[1 6 7]);

    
    for nback = [5 6]
        
        data_sub                                = data_behav(data_behav(:,1) == nback,:);
        
        i = i+1;
        behav_struct(i).suj                     = ['sub' num2str(suj_list(ns))];
        behav_struct(i).cond                    = [num2str(nback-4) 'back'];
        
        % behavioural response (1=hit, 2=miss, 3=cr, 4=fa)
        lngth_trials_all                        = length(data_sub);
        lngth_trials_target                     = length(data_sub(data_sub(:,2) == 1 | data_sub(:,2) == 2));
        lngth_trials_notarget                   = length(data_sub(data_sub(:,2) == 3 | data_sub(:,2) == 4));
        
        behav_struct(i).rt                      = median(data_sub(data_sub(:,3) > 0 & rem(data_sub(:,2),2) ~= 0,3)) / 1000;
        
        %         behav_struct(i).hit                     = length(data_sub(data_sub(:,2) == 1)) ./ lngth_trials_target; %lngth_trials_all; %
        %         behav_struct(i).miss                    = length(data_sub(data_sub(:,2) == 2)) ./ lngth_trials_target; %lngth_trials_all; %
        %         behav_struct(i).cr                      = length(data_sub(data_sub(:,2) == 3)) ./ lngth_trials_notarget; %lngth_trials_all; %
        %         behav_struct(i).fa                      = length(data_sub(data_sub(:,2) == 4)) ./ lngth_trials_notarget; %lngth_trials_all; %
        
        behav_struct(i).correct                 = length(data_sub(data_sub(:,2) == 1 | data_sub(:,2) == 3)) ./ lngth_trials_all;
        behav_struct(i).incorrect           	= length(data_sub(data_sub(:,2) == 2 | data_sub(:,2) == 4)) ./ lngth_trials_all;
        
        behav_struct(i).correct                 = behav_struct(i).correct .* 100;
        behav_struct(i).incorrect           	= behav_struct(i).incorrect .* 100;
        
    end
end

keep allperf allrt behav_struct dir_data_*

behav_table                                     = struct2table(behav_struct);

writetable(behav_table,[dir_data_out 'nback3_behav_data.csv']);

%% find outliers

[index_good,index_bad]                       	= calc_tukey(behav_table.incorrect);
[index_good,index_bad]                          = calc_tukey(behav_table.rt);
