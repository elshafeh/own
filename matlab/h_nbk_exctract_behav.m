function behav_struct = h_nbk_exctract_behav(suj)

load(['D:\Dropbox\project_me\data\nback\behav_h\sub' num2str(suj) '.behav.mat']);

data_behav                                  = data_behav(:,[1 6 7]);
i                                           = 0;

for nback = [4 5 6]
    
    data_sub                                = data_behav(data_behav(:,1) == nback,:);
    
    i = i+1;
    behav_struct(i).suj                     = ['sub' num2str(suj)];
    behav_struct(i).cond                    = [num2str(nback-4) 'back'];
    
    % behavioural response (1=hit, 2=miss, 3=cr, 4=fa)
    lngth_trials_all                        = length(data_sub);
    lngth_trials_target                     = length(data_sub(data_sub(:,2) == 1 | data_sub(:,2) == 2));
    lngth_trials_notarget                   = length(data_sub(data_sub(:,2) == 3 | data_sub(:,2) == 4));
    
    behav_struct(i).rt                      = median(data_sub(data_sub(:,3) > 0,3));
    behav_struct(i).match_hit               = length(data_sub(data_sub(:,2) == 1)) ./ lngth_trials_target;
    behav_struct(i).match_miss              = length(data_sub(data_sub(:,2) == 2)) ./ lngth_trials_target;
    
    behav_struct(i).nomatch_hit             = length(data_sub(data_sub(:,2) == 3)) ./ lngth_trials_notarget;
    behav_struct(i).nomatch_miss           	= length(data_sub(data_sub(:,2) == 4)) ./ lngth_trials_notarget;
    
    behav_struct(i).correct                 = length(data_sub(data_sub(:,2) == 1 | data_sub(:,2) == 3)) ./ lngth_trials_all;
    behav_struct(i).incorrect           	= length(data_sub(data_sub(:,2) == 2 | data_sub(:,2) == 4)) ./ lngth_trials_all;
    
end