clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_files            	= '~/Dropbox/project_me/data/nback/';
    ext_decode          	= 'stim';
    
    % load indices
    index_trials{1}         = [];
    index_trials{2}         = [];
    
    fname                   = [dir_files 'trialinfo/' sujname '.trialinfo.mat'];
    fprintf('loading %s\n',fname);
    load(fname);

    for nback = [1 2]
        
        % choose trials with target
        sub_info           	= trialinfo(trialinfo(:,1) == nback+4 & trialinfo(:,2) == 2,[4 5 6]);
        
        % remove incorrect trials for RT analyses
        sub_info_correct  	= sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:);
        
        % remove zeros
        sub_info_correct  	= sub_info_correct(sub_info_correct(:,2) ~= 0,:);
        
        % remove outliers
        [index_good,~]     	= calc_tukey(sub_info_correct(:,2));
        sub_info_correct  	= sub_info_correct(index_good,:);
        
        median_rt         	= median(sub_info_correct(:,2));
        
        %median split
        index_trials{1}    	= [index_trials{1} ; sub_info_correct(sub_info_correct(:,2) < median_rt,3)]; % fast
        index_trials{2}  	= [index_trials{2} ; sub_info_correct(sub_info_correct(:,2) > median_rt,3)]; % slow
        
    end
    
    list_rt                 = {'fast' 'slow'};
    
    for nrt = [1 2]
        
        index               = index_trials{nrt};
        dir_out             = '~/Dropbox/project_me/data/nback/bin_index/';
        fname_out         	= [dir_out 'sub' num2str(suj_list(nsuj)) '.' list_rt{nrt} '.newindex.target.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'index');
        
    end
    
end