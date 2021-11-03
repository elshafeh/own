clear;

mri_directory       = '~/Dropbox/project_me/data/pam/headfield/';
vol_directory       = mri_directory;

mri_list            = dir([mri_directory '*.mri']);

vox_res             = '0.5';

for nsuj = 1:length(mri_list)
    
    mri_name        = [mri_list(nsuj).folder filesep mri_list(nsuj).name];
    parts           = strsplit(mri_list(nsuj).name,'_');
    sujname         = parts{1};
    
    [vol, grid]   	= func_pam_create_normalisedHeadmodel(mri_name,['../data/stock/template_grid_' vox_res 'cm.mat']);
        
    fname_out       = [vol_directory sujname '_volgrid_' vox_res 'cm.mat'];
    
    save(fname_out,'vol','grid','-v7.3');
    
    clear vol grid sujname parts mri_name fname_out
    
end

