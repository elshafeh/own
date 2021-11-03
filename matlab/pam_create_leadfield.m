clear;

preproc_directory               = '~/Dropbox/project_me/data/pam/preproc/';
vol_directory                   = '~/Dropbox/project_me/data/pam/headfield/';

suj_list                        = {'yc1' 'yc2' 'yc3' 'yc4'};

vox_res                         = '0.5';

for nsuj = 1:length(suj_list)
    
    sujname                     = suj_list{nsuj};
    
    fname_in                 	= [vol_directory sujname '_volgrid_' vox_res 'cm.mat'];
    fprintf('loading: %s\n',fname_in);
    load(fname_in);
    
    % load in elan data or just the grad file
    fname_in                    = [preproc_directory sujname '.CnD.meg.mat'];
    fprintf('loading: %s\n',fname_in);
    load(fname_in);
    
    cfg                         = [];
    cfg.sourcemodel             = grid;
    cfg.headmodel               = vol;
    cfg.grad                    = data.grad;
    cfg.channel                 = 'MEG';
    leadfield                   = ft_prepare_leadfield(cfg);
    
    fname_out                   = [vol_directory sujname '_pt' num2str(npart) '_leadfield_' vox_res 'cm.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'leadfield','-v7.3');
    
    
end