clear ; 

% Do this for the FIRST subject ; so that you can generate a "template
% grid" 
% mrifilename is the mri file with V2.mri at the end

[vol, grid] = new_exemple_script_headmodel_normalized(mri_filename);

% save the vol and grid for that subject
% for the rest of the subjects: 
% mrifilename is the mri file with V2.mri at the end
% headshape_leadfield_backup_filename : is the template grid file

[vol, grid] = new_exemple_script_headmodel_normalized(mri_filename, headshape_leadfield_backup_filename);

% Once you have the vol and grid , you can create the leadfield
% load your data_elan file

cfg                 = [];
cfg.grid            = grid;
cfg.headmodel       = vol;
cfg.channel         = 'MEG';
cfg.grad            = data_elan.hdr.grad;
leadfield           = ft_prepare_leadfield(cfg);

% save the leadfield

