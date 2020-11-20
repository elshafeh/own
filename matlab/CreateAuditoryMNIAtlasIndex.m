h_startscript;

load ../data/template/template_grid_0.5cm.mat;

[all_index_H,~]             = h_createIndexfieldtrip(template_grid.pos,'../fieldtrip-20151124/');
roi_interest                = 79:82;
index_H                     = [];
list_H                      = {};

list_names                  = 'abcd';

for nroi = 1:length(roi_interest)
    
    new_tmp                 = all_index_H(all_index_H(:,2) == roi_interest(nroi),:);
    new_tmp(:,2)            = nroi;
    index_H                 = [index_H; new_tmp];
    list_H{nroi}            = list_names(nroi);
    
    clear new_tmp
    
end

clearvars -except index_H list_H

save('../data/index/MniAud.mat','index_H','list_H');