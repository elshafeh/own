clear ; clc ;

for sb = [1:4 8:17]
    
    suj = ['yc' num2str(sb)];
    
    mri_filename = ['../mri/' suj '_T1_converted_V2.mri'];
    [vol, grid] = new_5mm(mri_filename,'../data/template/template_grid_5mm.mat');
    save(['../data/' suj '/headfield/' suj '.VolGrid.5mm.mat'],'vol','grid');
    
    %     PrepAtt2_gp_build;
    
    for pt = 1:3
        
        load(['../data/' suj '/elan/' suj '.pt' num2str(pt) '.DIS3.mat'])
        
        hdr = ft_read_header(['/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/ds/' suj '.pat2.b' num2str(blc_grp{pt}(1)) '.ds']);
        
        cfg                 = [];
        cfg.grid            = grid;
        cfg.headmodel       = vol;
        cfg.channel         = 'MEG';
        cfg.grad            = data_elan.hdr.grad;
        leadfield           = ft_prepare_leadfield(cfg);
        
        save(['../data/' suj '/headfield/' suj '.pt' num2str(pt) '.adjusted.leadfield.5mm.mat'],'leadfield');
        
        clear data_elan
        
    end
    
    clearvars -except s
    
    close all;
    
end