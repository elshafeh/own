clear ; clc ;

suj = 'yc1' ;

polhemus                = ft_read_headshape(['/Volumes/h128ssd/alpha_compare/polhemus/' suj '.polh.pos']);

load elan_sens.mat ; clc ; elec = sens ; clear sens ;

elec.label{55} = 'Nz';
elec.label{56} = 'LPA';
elec.label{57} = 'RPA';

tmp                     = [polhemus.pnt(1:50,:) ; elec.elecpos(51,:); polhemus.pnt(51:end,:);polhemus.fid.pnt];

elec.chanpos            = tmp;
elec.elecpos            = tmp;

clear tmp ;

elec                    = ft_convert_units(elec,'mm');

mri                     = ft_read_mri(['/Volumes/h128ssd/alpha_compare/mri/' suj '_T1_converted_V2.mri']);

cfg                     = [];
cfg.downsample          = 1;
segmentedmri            = ft_volumesegment(cfg, mri);

cfg                     =   [];
bnd                     =   ft_prepare_mesh(cfg,segmentedmri);

cfg                     = [];
cfg.method              ='dipoli';
vol                     = ft_prepare_headmodel(cfg, bnd);

load(['/Volumes/h128ssd/alpha_compare/headfield/' suj '.VolGrid.5mm.mat'],'grid');

cfg                     = [];
cfg.grid                = grid;
cfg.headmodel           = vol;
cfg.elec                = elec;
cfg.channel             = 1:54;
leadfield               = ft_prepare_leadfield(cfg);

vol                     = ft_convert_units(vol,'cm');
elec                    = ft_convert_units(elec,'cm');

vol.MNI_pos             = grid.MNI_pos ;

save(['/Volumes/h128ssd/alpha_compare/headfield/' suj '.eegVolElecLead.mat'],'elec','vol','leadfield');

clear ; clc ;