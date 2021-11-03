clear ; clc;

load ../data/stock/template_grid_0.5cm.mat ;

for nsuj = 2:21
    
    subjectName                	= ['yc' num2str(nsuj)];
    
    list_time               	= {'nDLT.m0p200ms' 'nDRT.m0p200ms'};
    dir_in                      = '~/Dropbox/project_me/data/pam/source/';
    fname_in                    = [dir_in subjectName '.' list_time{1} '.lcmvsource.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    bsl                         = source; 
    
    fname_in                    = [dir_in subjectName '.' list_time{2} '.lcmvsource.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    act                         = source;
    
    
    source                    	= [];
    source.pos                 	= template_grid.pos;
    source.dim                	= template_grid.dim;
    source.pow                	= abs((act-bsl) ./ (act+bsl));
    
    vox_list                  	= [];
    
    cfg                         = [];
    cfg.atlas_path              = '~/github/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii';
    cfg.roi                     = 'auditory';
    cfg.direction               = 'max';
    cfg.number_voxels           = 1;
    cfg.hemisphere           	= 'left';
    [vox_list_l]             	= func_findmaxvox_pam(cfg,source);
    
    cfg.hemisphere           	= 'right';
    [vox_list_r]             	= func_findmaxvox_pam(cfg,source);
    
    save(['~/Dropbox/project_me/data/pam/vox/' subjectName '.maxvox.auditory.mat'],'vox_list_l','vox_list_r');
    
    clear vox_list*
    
end