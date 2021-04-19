clear;

mri_directory       = '~/Dropbox/project_me/data/pam/headfield/';
vol_directory       = mri_directory;

mri_list            = dir([mri_directory '*.mri']);

for nsuj = 1:length(mri_list)
    
    mri_name        = [mri_list(nsuj).folder filesep mri_list(nsuj).name];
    parts           = strsplit(mri_list(nsuj).name,'_');
    sujname         = parts{1};
    
    [vol, grid]   	= h_pam_createcreate_normalisedHeadmodel(mri_name, '../data/stock/template_grid_0.1cm.mat');
        
    fname_out       = [vol_directory sujname '_volgrid_0.1cm.mat'];
    
    save(fname_out,'vol','grid','-v7.3');
    
    clear vol grid sujname parts mri_name fname_out
    
end

