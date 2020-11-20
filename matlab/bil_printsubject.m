clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

suj_list                    = dir([project_dir 'data/sub*/tf/*cuelock.itc.comb.5binned.allchan.mat']);

% exclude bad subjects
excl_list                   = {'sub007'};
new_suj_list            	= [];
for ns = 1:length(suj_list)
    if ~ismember(suj_list(ns).name(1:6),excl_list)
        i = i+1;
        new_suj_list        = [new_suj_list;suj_list(ns)];
        
        fprintf('"%s",',suj_list(ns).name(1:6));
        
    end
end