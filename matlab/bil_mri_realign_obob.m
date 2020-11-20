function bil_mri_realign_obob

addpath('/home/mrphys/hesels/github/obob_ownft/');
obob_init_ft; close all;

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

if ~isempty(new_list)
    
    % select subject and find directory
    [indx,~]                        = listdlg('ListString',new_list(:,1),'ListSize',[200,200]);
    
    subjectName                     = new_list{indx,1};
    mri_dir                         = new_list{indx,2};
    
    if ~strcmp(mri_dir(end-2:end),'nii')
        [file,path]                 = uigetfile([mri_dir '/*.IMA'],'Select ONE file');
        mri_name                    = [path file];
    else
        mri_name                    = [];
    end
    
    polhemus_file                   = dir(['/project/3015079.01/meg_data/Polhemus/bil_' subjectName '.pos']);
    
    if strcmp(subjectName,'sub007')
        dir_data                    = '/home/mrphys/hesels/';
    elseif strcmp(subjectName,'sub037')
        dir_data                    = '/project/3015079.01/raw/sub-037/ses-meg01/meg/';
    else
        dir_data                    = '/project/3015079.01/raw/';
    end
    
    dsFileName                      = dir([dir_data subjectName '*.ds']);
    dsFileName                      = [dsFileName.folder '/' dsFileName.name];
    
    if ~isempty(polhemus_file)
        
        polhemus                   	= ft_read_headshape([polhemus_file(1).folder filesep polhemus_file(1).name]);
        polhemus.pos(polhemus.pos(:,3)<-10,:)=[];
        polhemus.unit             	='cm';
        polhemus.coordsys         	= 'ctf';
         
        cfg                         = [];
        cfg.mrifile                 = mri_name;
        cfg.headshape               = polhemus;
        %         cfg.sens                    = dsFileName;
        [mri_aligned,shape,hdm,mri_segmented]   = obob_coregister(cfg);
    end
    
    dir_out                         = '/project/3015039.06/bil/mri/'; %['/project/3015079.01/data/' subjectName '/mri/'];
    
end