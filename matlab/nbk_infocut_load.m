function index_trials = nbk_infocut_load(trialinfo,f_focus,zeros_action)


index_trials            = {};

for nback = [1 2]
    
    switch f_focus
        case 'target'
            % choose trials with target
            sub_info  	= trialinfo(trialinfo(:,1) == nback+4 & trialinfo(:,2) == 2,[4 5 6]);
        case 'all'
            % choose all trials
            sub_info   	= trialinfo(trialinfo(:,1) == nback+4,[4 5 6]);
    end
    
    % remove incorrect trials for RT analyses
    sub_info_correct            = sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:);
    
    % remove [or not] zeros
    switch zeros_action
        case 'remove'
            sub_info_correct  	= sub_info_correct(sub_info_correct(:,2) ~= 0,:);
    end
    
    %median split
    index_trials{nback}         = sub_info_correct(:,3); % fast
    
end

% subsample the 2back condition
index_trials_equal              = h_equalVectors(index_trials);
index_trials{3}                 = index_trials_equal{2};