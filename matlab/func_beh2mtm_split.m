function [index] = func_beh2mtm_split(data,stim_focus)


if isstruct(data)

    trialinfo             	= [];
    trialinfo(:,1)       	= data.trialinfo(:,1); % condition
    trialinfo(:,2)       	= data.trialinfo(:,3); % stim category
    trialinfo(:,3)       	= rem(data.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)       	= data.trialinfo(:,6); % response
    trialinfo(:,5)        	= data.trialinfo(:,7); % rt
    trialinfo(:,6)         	= 1:length(data.trialinfo); % trial indices to match with bin
    
else
    
    trialinfo               = data;
    
end

index{1}                    = []; % for fast
index{2}                    = []; % for slow

for nback  = [1 2]
    
    switch stim_focus
        case 'target'
            flg_nback_stim 	= find(trialinfo(:,1) == nback + 4 & trialinfo(:,2) == 2);
        case 'first'
            flg_nback_stim 	= find(trialinfo(:,1) == nback + 4 & trialinfo(:,2) == 1);
        case 'first&target'
            flg_nback_stim 	= find(trialinfo(:,1) == nback + 4 & (trialinfo(:,2) == 1 | trialinfo(:,2) == 2));

        case 'all'
            flg_nback_stim 	= find(trialinfo(:,1) == nback + 4);
    end
    
    sub_info              	= trialinfo(flg_nback_stim,[4 5 6]);
        
    sub_info_correct       	= sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
    sub_info_correct       	= sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
    
    % remove outliers
    [index_good,~]          = calc_tukey(sub_info_correct(:,2));
    sub_info_correct        = sub_info_correct(index_good,:);
    
    median_rt              	= median(sub_info_correct(:,2));
    
    index{1}                = [index{1}; sub_info_correct(find(sub_info_correct(:,2) < median_rt),3)]; % fast
    index{2}             	= [index{2}; sub_info_correct(find(sub_info_correct(:,2) > median_rt),3)]; % slow
    
    clear media_rt sub_info sub_info_correct
    
end