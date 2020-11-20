h_startscript;

load ../data/template/template_grid_2cm.mat;

index_H         = [];
list_H          = {};
i               = 0;

for nvoxel = 1:length(template_grid.pos)
    
    if template_grid.inside(nvoxel) == 1
        
        i           = i + 1;
        index_H     = [index_H; nvoxel i];
        list_H{i}   = ['vox' num2str(nvoxel)];
    end
    
end

clearvars -except *_H template_grid

save ../data/index/mni2cmWhole.mat ;

dir_fieldtrip                   = '/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/fieldtrip-20151124/';
vox_pos                         = template_grid.pos;
vox_pos                         = vox_pos(template_grid.inside == 1,:);
[region_indx,region_list]       = h_createIndexfieldtrip(vox_pos,dir_fieldtrip);

save('../data/index/mni2cmIndex.mat','region_indx');