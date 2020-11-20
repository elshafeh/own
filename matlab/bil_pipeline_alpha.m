clear ; clc;

if isunix
    project_dir     = '/project/3015079.01/';
else
    project_dir     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName    	= suj_list{nsuj};
    
    % erf prep - change locking to gratings
    %     bil_changelock_target_and_probe(subjectName);
    
    % compute erf [locked to gratings]
    %     bil_alpha_compute_erf(subjectName);
    
    % define erf window to select channels with maximum response
    %     bil_alpha_select_maxchan(subjectName,[0 0.2],20)
    
    % compute mtm [locked to firt cue]
    %     bil_alpha_mtm_compute(subjectName);
    
    % find alpha peak + binning
    bil_alpha_findalphapeak_bin(subjectName);
    
end