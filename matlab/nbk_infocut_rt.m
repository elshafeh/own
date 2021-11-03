function index_trials = nbk_infocut_rt(trialinfo,f_focus)


index_trials{1}            = [];
index_trials{2}            = [];


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
    
    % remove zeros
    sub_info_correct            = sub_info_correct(sub_info_correct(:,2) ~= 0,:);
    
    % remove outliers
    [index_good,~]              = calc_tukey(sub_info_correct(:,2));
    
    sub_info_correct            = sub_info_correct(index_good,:);
    
    median_rt                   = median(sub_info_correct(:,2));
    
    %median split
    index_trials{1}             = [index_trials{1} ; sub_info_correct(sub_info_correct(:,2) < median_rt,3)]; % fast
    index_trials{2}             = [index_trials{2} ; sub_info_correct(sub_info_correct(:,2) > median_rt,3)]; % slow
    
end