function [suj_mri_dir] = bil_find_mri

clc;

if ispc
    proj_dir    = 'P:/';
    home_dir    = 'H:/';
else
    proj_dir    = '/project/';
    home_dir    = '/home/';
end

suj_list                                = dir([proj_dir '3015079.01/data/sub*/preproc/*_firstCueLock_ICAlean_finalrej.mat']);
[nmbr,txt]                              = xlsread([proj_dir '3015079.01/doc/bil_sonaID.xlsx']);
txt                                     = txt(2:end,1);

suj_mri_dir                             = {};

for ns = 1:length(suj_list)
    
    subjectName                         = suj_list(ns).name(1:6);
    indx                                = find(strcmp(txt,subjectName));
    
    sona_id                             = num2str(nmbr(indx));
    
    new_subjectName                     = [subjectName(1:3) '-' subjectName(4:6)];
    mri_dir                             = dir([proj_dir '3015079.01/raw/' new_subjectName '/ses-mri01/*t1*/*IMA']); % /*/*IMA']);
    
    suj_mri_dir{ns,1}                   = subjectName;
    suj_mri_dir{ns,3}                   = sona_id;
    
    if ~isempty(mri_dir)
        suj_mri_dir{ns,2}               = mri_dir(1).folder;
    else
        
        if strcmp(sona_id,'153781')
            suj_mri_dir{ns,2}        	= [proj_dir '3015039.05/raw/sub-003/ses-mri01/'];
        else
            mri_dir                  	= dir([home_dir 'common/anatomical_mri/' sona_id '/*t1*/*IMA']);
            if ~isempty(mri_dir)
                suj_mri_dir{ns,2}      	= mri_dir(1).folder;
            else
                mri_dir              	= dir([home_dir 'common/anatomical_mri/' sona_id '/*IMA']);
                if ~isempty(mri_dir)
                    suj_mri_dir{ns,2} 	= mri_dir(1).folder;
                end
            end
        end
        
        if strcmp(subjectName,'sub013') || strcmp(subjectName,'sub023')
            suj_mri_dir{ns,2}   = [home_dir 'common/matlab/fieldtrip/template/anatomy/single_subj_T1.nii'];
        end
    end
    
end

empty_list                              = {};
i                                       = 0;

fprintf('subjects with no mri:\n');
for ns = 1:length(suj_mri_dir)
    if isempty(suj_mri_dir{ns,2})
        i               = i+1;
        empty_list{i}   = suj_mri_dir{ns,3};
        fprintf('%s : %s\n',suj_mri_dir{ns,1},suj_mri_dir{ns,3});
    end
end
fprintf('\n');