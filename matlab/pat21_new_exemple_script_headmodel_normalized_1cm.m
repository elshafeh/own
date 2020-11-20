function [vol, grid] = new_exemple_script_headmodel_normalized_1cm(mri_filename, headshape_leadfield_backup_filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Cette fonction va construire un model de t???te et un leadfield ??? partir de
% l'IR du sujet.
% Le leadfield est construit sur la base d'une grille normalis???e que l'on a
% d???fom???e. Ainsi les grilles de chaque sujets sont comparables entre elle,
% dans le m???me espace, en vue de pratiquer des statistiques.
%
% EX :
%     mri_filename     = 'Y:\Epilepto\CAT_Aurelie\MEG\mri\Test_V2.mri';     % provide by MRIConverter CTF software
%     mri_shape_filename = 'Y:\Epilepto\CAT_Aurelie\MEG\mri\Test_V2.shape';  % provide by MRIViewer CTF software
%
% Lorsque les fichier IRM proviennent des softs de CTF (MRIConverter,
% MRIViwer), les coordonn???es sont automatiquement transform???es en CTF selon
% les fiduciaux. Bien pratique pour le recalage de l'IRM sans passer par la
% fonction ft_volumerealign
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% paths initialization
%path_ft = 'C:\Data\Sauvegarde\Programmes_Matlab\Fieldtrip\fieldtrip-20151007';
% path_ft = '/Users/romain.bouet/Datas/Sauvegarde/Programmes_Matlab/Fieldtrip/fieldtrip-20151007';
% rmpath(genpath('C:\Data\Sauvegarde\Programmes_Matlab\Fieldtrip\'))
% addpath(genpath(path_ft))

%% Calcul ou pas d'un leadfield sur le MNI ?

if nargin == 2
    disp(['Load ' headshape_leadfield_backup_filename ' file'])
    load(headshape_leadfield_backup_filename)
    if  ~exist('template_grid', 'var')
        errordlg(['There is no template_grid variable in the ' headshape_leadfield_backup_filename 'file'])
        return
    end
else
    
    fprintf('Make the template grid\n')
    
    template = ft_read_mri(['../fieldtrip-20151124/template/anatomy/single_subj_T1_1mm.nii']);
    template.coordsys = 'spm';
    
    
    fprintf('Segment the template brain\n')
    
    % segment the template brain and construct a volume conduction model (i.e. head model)
    
    cfg          = [];
    template_seg = ft_volumesegment(cfg, template);
    
    fprintf('Construct a template volume conduction model\nSingleshell method\n')
    cfg          = [];
    cfg.method   = 'singleshell';
    template_vol = ft_prepare_headmodel(cfg, template_seg);
    template_vol = ft_convert_units(template_vol, 'cm');
    
    fprintf('Construct the dipole grid in the template brain\n')
    
    % construct the dipole grid in the template brain coordinates the source units are in cm
    
    cfg = [];
    cfg.grid.xgrid  = -20:1:20;
    cfg.grid.ygrid  = -20:1:20;
    cfg.grid.zgrid  = -20:1:20;
    cfg.grid.unit   = 'cm';
    cfg.grid.tight  = 'yes';
    cfg.inwardshift = -1;               %  outward shift of the brain surface for inside/outside detection
    cfg.headmodel         = template_vol;
    template_grid   = ft_prepare_sourcemodel(cfg);
    
    % % make a figure with the template head model and dipole grid
    
    save('../data/template/template_grid_1cm.mat','template_grid');
    
    %     figure, hold on
    %     ft_plot_vol(template_vol, 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
    %     ft_plot_mesh(template_grid.pos(template_grid.inside,:));
    %     ft_plot_mesh(hdr.grad.chanpos);
    
    
end



%%
fprintf('\nMake the individual subjects grid\n')

disp('Load MRI file')

% read the single subject anatomical MRI

mri = ft_read_mri(mri_filename);

% mri = ft_volumereslice([], mri);

fprintf('Segment the individual brain\n')

% segment the anatomical MRI

cfg = [];
cfg.downsample = 1;
seg = ft_volumesegment(cfg, mri);

%check segmented volume against mri

mri.brainmask = seg.gray+seg.white+seg.csf;
cfg              = [];
cfg.interactive  = 'yes';
cfg.funparameter = 'brainmask';
% figure, hold on
% ft_sourceplot(cfg, mri);



%% Comput leadfield(s)

% construct volume conductor model (i.e. head model) for each subject

fprintf('Construct a individual volume conduction model\nSingleshell method\n')
cfg             = [];
cfg.method      = 'singleshell';
vol             = ft_prepare_headmodel(cfg, seg);
vol             = ft_convert_units(vol, 'cm');
vol.MNI_pos = template_grid.pos;

fprintf('Create the individual specific grid, using the template grid\n')

cfg                = [];
cfg.grid.warpmni   = 'yes';
cfg.grid.template  = template_grid;
cfg.grid.nonlinear = 'yes'; % use non-linear normalization
cfg.mri            = mri;
grid               = ft_prepare_sourcemodel(cfg);

% Ici on ne construit que le model de source (o??? quelles sont les sources possibles ?). Le leadfield (forward model) n'est pas encore
% calcul???. C'est pourquoi les informations de positions des gradiom???tres
% n'ont aucune importance

grid.MNI_pos = template_grid.pos;


% make a figure of the single subject headmodel, and grid positions

% figure, hold on
% ft_plot_vol(vol, 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
% ft_plot_mesh(grid.pos(template_grid.inside,:), 'vertexcolor', [0 0 0]);
% ft_plot_mesh(hdr.grad.chanpos);