function bil_mri_realign

global ft_default
ft_default.spmversion               = 'spm12';

dir_list                            = bil_find_mri;
new_list                            = {};
i                                   = 0;

for n = 1:length(dir_list)
    % remove subjects with no mri [yet]
    if ~isempty(dir_list{n,2})
        % remove subjects with already processed rmi
        if ~exist(['/project/3015039.06/bil/mri/' dir_list{n,1} '.mri.polh.realigned.mat'])
            i                       = i +1;
            new_list{i,1}           = dir_list{n,1};
            new_list{i,2}           = dir_list{n,2};
        end
    end
end

keep new_list;

if ispc
    proj_dir    = 'P:/';
    home_dir    = 'H:/';
else
    proj_dir    = '/project/';
    home_dir    = '/home/';
end

if ~isempty(new_list)
    
    % select subject and find directory
    [indx,~]                        = listdlg('ListString',new_list(:,1),'ListSize',[200,200]);
    
    subjectName                     = new_list{indx,1};
    mri_dir                         = new_list{indx,2};
    
    if ~strcmp(mri_dir(end-2:end),'nii')
        [file,path]                 = uigetfile([mri_dir '/*.IMA'],'Select ONE file');
        mri_name                    = [path file];
    else
        mri_name                    = new_list{indx,2};
    end
    
    % read the DICOM files
    mri                             = ft_read_mri(mri_name);
    
    % Making sure you know which side is the right side (e.g. using the vitamin E marker),
    % assign the nasion (pressing "n"), left ("l") and right ("r") with the crosshairs on
    % the ear markers. Then finish with "q".
    
    cfg                             = [];
    cfg.method                      = 'interactive';
    cfg.coordsys                    = 'ctf';
    mri_realigned_ctf             	= ft_volumerealign(cfg,mri);
    
    polhemus_file                   = dir([proj_dir '3015079.01/meg_data/Polhemus/bil_' subjectName '.pos']);
    
    if ~isempty(polhemus_file)
        
        polhemus                    = ft_read_headshape([polhemus_file(1).folder filesep polhemus_file(1).name]);
        polhemus.pos(polhemus.pos(:,3)<-10,:)=[];
        polhemus.unit               ='cm';
        
        cfg                         = [];
        cfg.coordsys                = 'ctf';
        cfg.parameter               = 'anatomy';
        cfg.viewresult              = 'yes';
        cfg.method                  = 'headshape';
        cfg.headshape.headshape     = polhemus;
        cfg.headshape.interactive   = 'yes';
        cfg.headshape.icp           = 'no';
        mri_realigned_polh      	= ft_volumerealign(cfg, mri_realigned_ctf);
        
    else
        
        mri_realigned_polh         	= mri_realigned_ctf;
        
    end
    
    dir_out                         = [proj_dir '3015039.06/bil/mri/']; %['/project/3015079.01/data/' subjectName '/mri/'];
    fname                           = [dir_out subjectName '.mri.polh.realigned.mat'];
    save(fname,'mri_realigned_ctf','mri_realigned_polh','-v7.3');
    fprintf('\nDone!');
    
end