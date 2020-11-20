clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

list_initials               = lower({'SEGPE','NICJU','ALVJO','SINCA','TURBA','BARFA','BARBE','MONLE','BALAN','HUBVE','VIDAU','CORYA','FOUMA','SIRLU','DORGW'});
list_codes                  = lower({'YC1','YC2','YC3','YC4','YC8','YC9','YC10','YC11','YC12','YC13','YC14','YC15','YC16','YC17','YC18'});


for sb = 1:14
    
    suj_list                = [1:4 8:17];
    
    suj                     = ['yc' num2str(suj_list(sb))] ;
    
    suj_indx                = find(strcmp(list_codes,suj));
    suj_init                = list_initials{suj_indx};
    
    mri                     = ft_read_mri(['../data/mri/' suj '_T1_converted_V2.mri']);
    
    cfg                     = [];
    cfg.downsample          = 1;
    segmentedmri            = ft_volumesegment(cfg, mri);
    
    cfg                     = [];
    bnd                     = ft_prepare_mesh(cfg,segmentedmri);
    
    cfg                     = [];
    cfg.method              ='dipoli';
    vol                     = ft_prepare_headmodel(cfg, bnd);
    
    load elan_sens.mat ; clc ; elec = sens ; clear sens ;
    
    elec.label{55}          = 'Nz';
    elec.label{56}          = 'LPA';
    elec.label{57}          = 'RPA';
    
    polhemus                = ft_read_headshape(['../data/polhemus/' suj_init '.polh.pos']);
    
    if strcmp(suj,'yc1')
        tmp                 = [polhemus.pnt(1:50,:) ; elec.elecpos(51,:); polhemus.pnt(51:end,:);polhemus.fid.pnt];
        elec.chanpos        = tmp;
        elec.elecpos    	= tmp;
    else
        elec.chanpos        = [polhemus.pnt; polhemus.fid.pnt];
        elec.elecpos        = [polhemus.pnt; polhemus.fid.pnt];
    end
    
    elec                    = ft_convert_units(elec,'mm');
    
    load(['/Volumes/heshamshung/alpha_compare/headfield/' suj '.VolGrid.5mm.mat'],'grid');
    
    cfg                     = [];
    cfg.grid                = grid;
    cfg.headmodel           = vol;
    cfg.elec                = elec;
    cfg.channel             = 1:54;
    leadfield               = ft_prepare_leadfield(cfg);
    
    vol                     = ft_convert_units(vol,'cm');
    elec                    = ft_convert_units(elec,'cm');
    
    vol.MNI_pos             = grid.MNI_pos ;
    
    save(['/Volumes/heshamshung/alpha_compare/headfield/' suj '.eegVolElecLead.mat'],'elec','vol','leadfield');
    save(['../data/eegvol/' suj '.eegVolElecLead.mat'],'elec','vol','leadfield');
    
    clearvars -except sb ;
    
end