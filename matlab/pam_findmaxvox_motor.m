clear ; clc;

load ../data/stock/template_grid_0.5cm.mat ;

for nsuj = 2:21
    
    subjectName                	= ['yc' num2str(nsuj)];
    
    list_time               	= {'nBP.m600m100ms' 'nBP.m100p400ms'};
    
    dir_in                      = '~/Dropbox/project_me/data/pam/source/';
    fname_in                    = [dir_in subjectName '.' list_time{1} '.lcmvsource.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    bsl                         = source; % abs(source);
    
    fname_in                    = [dir_in subjectName '.' list_time{2} '.lcmvsource.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    act                         = source; % abs(source);
    
    
    source                    	= [];
    source.pos                 	= template_grid.pos;
    source.dim                	= template_grid.dim;
    source.pow                	= (act-bsl) ./ (bsl);
        
    cfg                         = [];
    cfg.atlas_path              = '~/github/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii';
    cfg.roi                     = 'motor';
    cfg.number_voxels           = 5;
    
    cfg.direction               = 'max';
    cfg.hemisphere           	= 'left';
    [vox_list_l]             	= func_findmaxvox_pam(cfg,source);
    
    cfg.direction               = 'min';
    cfg.hemisphere           	= 'right';
    [vox_list_r]             	= func_findmaxvox_pam(cfg,source);
    
    save(['~/Dropbox/project_me/data/pam/vox/' subjectName '.maxvox.motor.mat'],'vox_list_l','vox_list_r');
    
end