function ade_sfn_mri_preprocess(subjectName)

global ft_default
ft_default.spmversion   = 'spm12';

[~,~,dir_list]          = xlsread('../docs/ade_mri.xlsx','A:D');
dir_list                = array2table(dir_list(2:end,:),'VariableNames',dir_list(1,:));

find_suj                = find(strcmp([dir_list.ade_id],subjectName));
mri_dir                 = dir_list(find_suj,:).mri_directory{:};

[file,path]             = uigetfile([mri_dir '*.IMA'],'Select ONE file');

mri_name                = [path file];

% read the DICOM files
mri                     = ft_read_mri(mri_name);

% Making sure you know which side is the right side (e.g. using the vitamin E marker),
% assign the nasion (pressing "n"), left ("l") and right ("r") with the crosshairs on
% the ear markers. Then finish with "q".

cfg                     = [];
cfg.method              = 'interactive';
cfg.coordsys            = 'ctf';
mri_realigned           = ft_volumerealign(cfg,mri); 

% read the single subject anatomical MRI
mri                     = ft_volumereslice([], mri_realigned);
mri.coordsys            = 'ctf';

% segment the anatomical MRI
cfg                     = [];
cfg.downsample          = 1;
seg                     = ft_volumesegment(cfg, mri);

dir_out                 = ['../data/' subjectName '/mri/'];
mkdir(dir_out);
fname                   = [dir_out subjectName '_segmentMRI.mat'];

save(fname,'seg','mri','-v7.3');
fprintf('\nDone!');