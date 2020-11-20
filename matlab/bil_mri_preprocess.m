function bil_mri_preprocess

global ft_default
ft_default.spmversion   = 'spm12';

dir_list                = bil_find_mri;
new_list                = {};
i                       = 0;

for n = 1:length(dir_list)
    
    % remove subjects with no mri [yet]
    if ~isempty(dir_list{n,2})
        % remove subjects with already processed rmi
        %         if ~exist(['/project/3015079.01/data/' dir_list{n,1} '/mri/' dir_list{n,1} '.processedmri.plusnas.mat'])
        if ~exist(['/project/3015039.06/bil/mri/' dir_list{n,1} '.processedmri.plusnas.mat'])
            if ~strcmp(dir_list{n,2}(end-2:end),'nii')
                i               = i +1;
                new_list{i,1}   = dir_list{n,1};
                new_list{i,2}   = dir_list{n,2};
                
            end
        end
    end
end

keep new_list;


if ~isempty(new_list)
    
    % select subject and find directory
    [indx,~]                    = listdlg('ListString',new_list(:,1),'ListSize',[200,200]);
    
    subjectName                 = new_list{indx,1};
    mri_dir                     = new_list{indx,2};
    
    [file,path]                 = uigetfile([mri_dir '/*.IMA'],'Select ONE file');
    
    mri_name                    = [path file];
    
    % read the DICOM files
    mri                         = ft_read_mri(mri_name);
    
    % Making sure you know which side is the right side (e.g. using the vitamin E marker),
    % assign the nasion (pressing "n"), left ("l") and right ("r") with the crosshairs on
    % the ear markers. Then finish with "q".
    
    cfg                         = [];
    cfg.method                  = 'interactive';
    cfg.coordsys                = 'ctf';
    mri_realigned               = ft_volumerealign(cfg,mri);
    
    % read the single subject anatomical MRI
    mri                         = ft_volumereslice([], mri_realigned);
    mri.coordsys                = 'ctf';
    
    % segment the anatomical MRI
    cfg                         = [];
    cfg.downsample              = 1;
    seg                         = ft_volumesegment(cfg, mri);
    
    dir_out                     = '/project/3015039.06/bil/mri/'; %['/project/3015079.01/data/' subjectName '/mri/'];
    mkdir(dir_out);
    fname                       = [dir_out subjectName '.processedmri.plusnas.mat'];
    
    save(fname,'seg','mri','-v7.3');
    fprintf('\nDone!');
    
end