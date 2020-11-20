clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

suj_list = {'yc1'};

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    vox_size        = 0.5;
    
    mri_filename    = ['/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/mri/' suj '_T1_V2.mri'];
    template_file   = ['/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/data_fieldtrip/template/template_grid_' num2str(vox_size) 'cm.mat'];
    
    find_template   = dir(template_file);
    
    if length(find_template) ~=1
        [vol, grid] = h_create_normalisedHeadmodel(mri_filename,'',vox_size);
    else
        [vol, grid] = h_create_normalisedHeadmodel(mri_filename,template_file,vox_size);
    end
    
    %     save(['/mnt/autofs/Aurelie/DATA/MEG/PAT_MEG21/pat.field/data/' suj '.VolGrid.' num2str(vox_size) 'cm.mat'],'vol','grid');
    
    DsName              = ['/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/ds/' suj '.pat2.b1.ds'];
    hdr                 = ft_read_header(DsName);
    
    cfg                 = [];
    cfg.grid            = grid;
    cfg.headmodel       = vol;
    cfg.channel         = 'MEG';
    cfg.grad            = hdr.grad;
    leadfield           = ft_prepare_leadfield(cfg);
    
    %     save(['/mnt/autofs/Aurelie/DATA/MEG/PAT_MEG21/pat.field/data/' suj '.adjusted.leadfield.pt' num2str(prt) '.' num2str(vox_size) 'cm.mat'],'leadfield');
    
    clearvars -except suj_list sb
    
end

