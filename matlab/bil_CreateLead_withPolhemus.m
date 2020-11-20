clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
else
    project_dir                     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    dir_list                        = bil_find_mri;
    new_list                        = {};
    i                               = 0;
    
    for n = 1:length(dir_list)
        
        % remove subjects with no mri [yet]
        if ~isempty(dir_list{n,2})
            % remove subjects with already processed rmi
            i                   = i +1;
            new_list{i,1}       = dir_list{n,1};
            new_list{i,2}       = dir_list{n,2};
            
        end
    end
    
    if ~isempty(new_list)
        
        % select subject and find directory
        [indx,~]                    = listdlg('ListString',new_list(:,1),'ListSize',[200,200]);
        
        subjectName                 = new_list{indx,1};
        mri_dir                     = new_list{indx,2};
        
        [file,path]                 = uigetfile([mri_dir '/*.IMA'],'Select ONE file');
        
        mri_name                    = [path file];
        
    end
    
    mri_orig                        = ft_read_mri(mri_name);

    cfg                             = [];
    cfg.method                      = 'interactive';
    cfg.coordsys                    = 'ctf';
    mri_realigned                   = ft_volumerealign(cfg,mri_orig);
    mri_realigned                	= ft_convert_units(mri_realigned, 'mm');

    
    polh_name                       = ['/project/3015079.01/meg_data/Polhemus/bil_' subjectName '.pos'];
    
    if exist(polh_name)
        headshape                   = ft_read_headshape(polh_name);
        headshape                   = ft_convert_units(headshape, 'mm');
        
        cfg                         = [];
        cfg.method                  = 'headshape';
        cfg.headshape.interactive   = 'yes';
        cfg.headshape.icp           = 'yes';
        cfg.headshape.headshape     = headshape;
        cfg.coordsys                = 'ctf';
        cfg.spmversion              = 'spm12';
        mri_realigned_withpol    	= ft_volumerealign(cfg, mri_realigned);
        mri_realigned_withpol.coordsys      = 'ctf'; % remember that it is in ctf coordinates
        
        mri                         = ft_volumereslice([], mri_realigned);
        
        
        % segment the anatomical MRI
        cfg                         = [];
        cfg.downsample              = 1;
        seg                         = ft_volumesegment(cfg, mri);
        
    end
end