clear ; clc ;

for sb = 1:13
    
    suj_list = [2:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))] ;
    
    mri = ft_read_mri(['../mri/' suj '_T1_converted_V2.mri']);
    
    cfg             = [];
    cfg.downsample  = 1;
    segmentedmri    = ft_volumesegment(cfg, mri);
    
    %     cfg           = [];
    %     cfg.output    = {'brain','skull','scalp'};
    %     segmentedmri  = ft_volumesegment(cfg, mri);
    
    cfg                 =   [];
    %     cfg.tissue          =   {'brain','skull','scalp'};
    %     cfg.numvertices     =   [3000 2000 1000];
    bnd                 =   ft_prepare_mesh(cfg,segmentedmri);
    
    cfg                 = [];
    cfg.method          ='dipoli';
    vol                 = ft_prepare_headmodel(cfg, bnd);
    
    load elan_sens.mat ; clc ; elec = sens ; clear sens ;
    
    elec.label{55} = 'Nz';
    elec.label{56} = 'LPA';
    elec.label{57} = 'RPA';
    
    polhemus = ft_read_headshape(['../data/polhemus/' suj '.polh.pos']);
    
    elec.chanpos = [polhemus.pnt; polhemus.fid.pnt];
    elec.elecpos = [polhemus.pnt; polhemus.fid.pnt];
    
    elec = ft_convert_units(elec,'mm');
    
    load(['../data/' suj '/headfield/' suj '.VolGrid.5mm.mat'],'grid');
    
    cfg                 = [];
    cfg.grid            = grid;
    cfg.headmodel       = vol;
    cfg.elec            = elec;
    cfg.channel         = 1:54;
    leadfield           = ft_prepare_leadfield(cfg);
    
    vol     = ft_convert_units(vol,'cm');
    elec    = ft_convert_units(elec,'cm');
    
    vol.MNI_pos = grid.MNI_pos ;
    
    save(['../data/' suj '/headfield/' suj '.eegVolElecLead.mat'],'elec','vol','leadfield');
    
    clearvars -except sb ;
    
end

% figure;
% ft_plot_sens(elec,'style','sk');
% hold on;
% ft_plot_mesh(vol.bnd(2),'facealpha', 0.85, 'edgecolor', 'none', 'facecolor', [0.65 0.65 0.65]);

% figure, hold on
% ft_plot_mesh(vol_eeg.bnd(2), 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
% ft_plot_mesh(grid.pos(grid.inside,:), 'vertexcolor', [0 0 0]);
% ft_plot_sens(elec,'style','sk');
%
% figure
% ft_plot_mesh(vol_eeg.bnd(2), 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
%
% figure,
% ft_plot_sens(elec,'style','sk');
%
% figure
% ft_plot_mesh(grid.pos(grid.inside,:), 'vertexcolor', [0 0 0]);
%
% figure, hold on
% ft_plot_mesh(vol_eeg.bnd(2), 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
% ft_plot_mesh(grid.pos(grid.inside,:), 'vertexcolor', [0 0 0]);
%
% figure, hold on
% ft_plot_mesh(vol_eeg.bnd(2), 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
% ft_plot_sens(elec,'style','sk','label','yes');