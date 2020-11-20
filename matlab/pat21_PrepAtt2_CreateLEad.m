clear ; clc ; dleiftrip_addpath;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    vox_size     = 2;
    
    mri_filename = ['/dycog/Aurelie/DATA/MEG/PAT_MEG21/pat.meeg/data/' suj '/mri/processed/' suj '_T1_converted_V2.mri'];
    
    if sb == 1
        [vol, grid] = h_create_normalisedHeadmodel(mri_filename,'',vox_size);
    else
        [vol, grid] = h_create_normalisedHeadmodel(mri_filename,['../data/template/template_grid_' num2str(vox_size) 'cm.mat'],vox_size);
    end
    
    save(['../data/headfield/' suj '.VolGrid.' num2str(vox_size) 'cm.mat'],'vol','grid');
    
    %     load(['../headfield/' suj '.VolGrid.1cm.mat'])
    
    PrepAtt2_gp_build;
    
    for pt = 1:3
        
        hdr                 = ft_read_header(['/dycog/Aurelie/DATA/MEG/PAT_MEG21/pat.meeg/data/' suj '/ds/' suj '.pat2.b' num2str(blc_grp{pt}(1)) '.ds']);
        
        cfg                 = [];
        cfg.grid            = grid;
        cfg.headmodel       = vol;
        cfg.channel         = 'MEG';
        cfg.grad            = hdr.grad;
        leadfield           = ft_prepare_leadfield(cfg);
        
        save(['../data/headfield/' suj '.pt' num2str(pt) '.adjusted.leadfield.' num2str(vox_size) 'cm.mat'],'leadfield');
        
        clear hdr
        
    end
    
    clearvars -except s
    
    close all;
    
end