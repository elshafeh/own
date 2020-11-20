clear ; clc ;

suj = 'yc2' ;

polhemus = ft_read_headshape(['../data/polhemus/' suj '.polh.pos']);

load(['../data/' suj '/headfield/' suj '.VolGrid.5mm.mat']);

load elan_sens.mat ; clc ; elec = sens ; clear sens ;

elec.label{55} = 'Nz';
elec.label{56} = 'LPA';
elec.label{57} = 'RPA';

elec.chanpos = [polhemus.pnt; polhemus.fid.pnt];
elec.elecpos = [polhemus.pnt; polhemus.fid.pnt];

elec = ft_convert_units(elec,'cm');

cfg                 = [];
cfg.grid            = grid;
cfg.headmodel       = vol;
cfg.elec            = elec;

leadfield           = ft_prepare_leadfield(cfg);

% mri = ft_read_mri(['../mri/' suj '_T1_converted_V2.mri']);
% 
% Nz      = mri.hdr.fiducial.mri.nas;
% lpa     = mri.hdr.fiducial.mri.lpa;
% rpa     = mri.hdr.fiducial.mri.rpa;
% 
% transm=mri.transform;
%  
% Nz      =   ft_warp_apply(transm , Nz  , 'homogenous');
% lpa     =   ft_warp_apply(transm , lpa , 'homogenous');
% rpa     =   ft_warp_apply(transm , rpa , 'homogenous');
% 
% fid.elecpos       = [Nz; lpa; rpa];         % ctf-coordinates of fiducials
% fid.label         = {'Nz','LPA','RPA'};     % same labels as in elec 
% fid.unit          = 'cm';                   % same units as mri
% % alignment
% 
% cfg               = [];
% cfg.method        = 'fiducial';            
% cfg.target        = fid;                   % see above
% cfg.elec          = elec;
% cfg.fiducial      = {'Nz', 'LPA', 'RPA'};  % labels of fiducials in fid and in elec
% elec_aligned      = ft_electroderealign(cfg);
% 
% figure;
% ft_plot_sens(elec,'style','sk');
% hold on;
% ft_plot_mesh(vol.bnd,'facealpha', 0.85, 'edgecolor', 'none', 'facecolor', [0.65 0.65 0.65]); %scalp