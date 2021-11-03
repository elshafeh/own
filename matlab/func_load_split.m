function [index] = func_load_split(cfg_in,data)


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

for nback  = [1 2]
    
    switch cfg_in.stim_focus
        case 'target'
            flg_nback_stim      = find(trialinfo(:,1) == nback + 4 & trialinfo(:,2) == 2);
        case 'first'
            flg_nback_stim      = find(trialinfo(:,1) == nback + 4 & trialinfo(:,2) == 1);
        case 'all'
            flg_nback_stim      = find(trialinfo(:,1) == nback + 4);
    end
    
    sub_info                    = trialinfo(flg_nback_stim,[4 5 6]);
        
    switch cfg_in.incorrect
        case 'remove'
            sub_info_correct   	= sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
        case 'keep'
            sub_info_correct	= sub_info;
    end
    
    switch cfg_in.zeros
        case 'remove'
            sub_info_correct	= sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
        case 'keep'
            sub_info_correct	= sub_info_correct;
    end
    
    % remove outliers
    switch cfg_in.outliers
        case 'remove'
            [index_good,~]      = calc_tukey(sub_info_correct(:,2));
        case 'keep'
            index_good          = 1:length(sub_info_correct);
    end
        
    index{nback}                = sub_info_correct(index_good,3); % fast
    
    clear media_rt sub_info sub_info_correct
    
end

switch cfg_in.equalize
    case 'yes'
        index_trials_equal    	= h_equalVectors(index);
        index                   = index_trials_equal;
end