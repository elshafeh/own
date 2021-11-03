clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                           	= [1:33 35:36 38:44 46:51]; % []
load ../data/stock/template_grid_0.5cm.mat ;

atlas_path                          = '/Users/heshamelshafei/github/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii';
[region_index,region_name]          = h_createIndexfieldtrip(template_grid.pos,atlas_path);

for nsuj = 1:length(suj_list)
    
    subjectname                  	= ['sub' num2str(suj_list(nsuj))];
    
    list_time                       = {'m200m100ms' 'p70p170ms'};
    
    max_vox                         = [];
    tmp                             = [];
    
    for ntime = [1 2]
        
        fname_out                   = ['~/Dropbox/project_me/data/nback/source/lcmv/' subjectname '.allback.allstim'];
        fname_out                	= [fname_out '.' list_time{ntime} '.lcmvCombined.mat'];
        fprintf('Loading %s\n',fname_out);
        
        load(fname_out);
        
        tmp(:,ntime)              	= source; clear source;
        
    end
    
    source                      	= [];
    source.pos                   	= template_grid.pos;
    source.dim                  	= template_grid.dim;
    source.pow                    	= (tmp(:,2) - tmp(:,1)) ./ tmp(:,1);

    cfg                             = [];
    cfg.direction                   = 'max';
    cfg.region_index                = region_index;
    cfg.region_name                 = region_name;
    cfg.number_voxels               = 1;
    cfg.focus                       = {'Calcarine' 'Cuneus' 'Occipital'};
    
    % find max in LEFT hemisphere
    cfg.hemisphere                  = 'left';
    [vox_list]                      = h_findMaxVoxelPerRegion(cfg,source);
    max_vox                         = [max_vox;vox_list(1,:).Index];
    
    % find max in RIGHT hemisphere
    cfg.hemisphere                  = 'right';
    [vox_list]                      = h_findMaxVoxelPerRegion(cfg,source);
    max_vox                         = [max_vox;vox_list(1,:).Index];
    
    [roi_pos,roi_name]              = xlsread('../doc/wallis_roi.xlsx');
    roi_pos                         = round(roi_pos ./ 10);
    
    for n = 1:length(roi_pos)
        
        vct                         = source.pos;
        fnd_vox                  	= find(vct(:,1) == roi_pos(n,1) & vct(:,2) == roi_pos(n,2) & vct(:,3) ==roi_pos(n,3));
        source.pow(fnd_vox)         = 1;
        max_vox                     = [max_vox;fnd_vox];clear fnd_vox;
        
    end
    
    index_name                      = [{'max occ L'; 'max occ R'};roi_name]; % adapt NAMES
    index_vox                       = [max_vox [1:length(max_vox)]'];
    
    fname_out                       = ['~/Dropbox/project_me/data/nback/virt/' subjectname '.wallis.index.mat'];
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'index_name','index_vox');
    
    keep nsuj suj_list n region_* template_grid
    
end