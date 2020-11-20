clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list = 7:21;

for sb = 1:length(suj_list)
    
    suj                 = ['yc' num2str(suj_list(sb))];
    
    vox_size            = 2;
    
    %     if sb < 4
    %         mri_filename    = ['/Volumes/heshamshung/pat22_mri/' suj '_T1_V2.mri'];
    %     else
    mri_filename        = ['/Volumes/heshamshung/pat22_mri/' suj '_V2.mri'];
    %     end
    
    template_file       = ['../data/template/template_grid_' num2str(vox_size) 'cm.mat'];
    
    find_template       = dir(template_file);
    
    if length(find_template) ~=1
        [vol, grid]     = h_create_normalisedHeadmodel(mri_filename,'',vox_size);
    else
        [vol, grid]     = h_create_normalisedHeadmodel(mri_filename,template_file,vox_size);
    end
    
    DsName              = ['/Volumes/heshamshung/pat22_ds/' suj '.pat2.b1.thirdOrder.deljump.retraitOffset.ds'];
    hdr                 = ft_read_header(DsName);
    
    cfg                 = [];
    cfg.grid            = grid;
    cfg.headmodel       = vol;
    cfg.channel         = 'MEG';
    cfg.grad            = hdr.grad;
    leadfield           = ft_prepare_leadfield(cfg);
    
    fprintf('Saving Leadfield for %s\n',suj)
    
    save(['/Volumes/heshamshung/new_leadfield/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat'],'leadfield');
    
    clearvars -except suj_list sb
    
end

