clear ; clc ;

% Create leadfields that are block-adapted.

for s = [1:4 8:17]
    
    suj = ['yc' num2str(s)];
    
    % This shouldn't change : template
    % mri_filename = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/mri/processed/' suj '_T1_converted_V2.mri'];
    % [vol, grid] = new_exemple_script_headmodel_normalized_1cm(mri_filename,'/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.field/data/template/template_grid_1cm.mat');
    
    load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.field/data/' suj '/headfield/' suj '.VolGrid.1cm.mat'],'vol','grid');
    
    if strcmp(suj,'yc1')
        nseq=14;
    else
        nseq=15;
    end
    
    st_cov_ds = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/ds/' suj '.pat2.b'];
    st_raw_ds = dir(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/rawdata/' suj ]);
    st_raw_ds = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/rawdata/' suj '/' st_raw_ds(end).name(1:end-5)];
    
    idx_cov_ds = 1:nseq;
    
    % Copy hc files & create leadfield
    
    for n = 1:nseq
       
        %         if idx_raw_ds(n) < 10
        %         hc1 = [st_raw_ds '0' num2str(idx_raw_ds(n)) '.ds/*.hc'];
        %         else
        %         hc1 = [st_raw_ds num2str(idx_raw_ds(n)) '.ds/*.hc']  ;
        %         end
        %
        %         hc2 = [st_cov_ds num2str(idx_cov_ds(n)) '.ds/*.hc'] ;
        %
        %         ls(hc1);ls(hc2);
        %
        %         system(['cp ' hc1 ' ' hc2]);
       
        hdr = ft_read_header([st_cov_ds num2str(idx_cov_ds(n)) '.ds']);
        
        cfg           = [];
        cfg.grid      = grid;
        cfg.headmodel = vol;
        cfg.channel   = 'MEG';
        cfg.grad      = hdr.grad;
        leadfield     = ft_prepare_leadfield(cfg, []);
        
        save(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.field/data/' suj '/headfield/' suj '.b' num2str(n) '.adjusted.leadfield.1cm.mat'],'leadfield');
        
        clear hdr leadfield hc hc2
        
    end
    
    clearvars -except s
    
end