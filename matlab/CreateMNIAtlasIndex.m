h_startscript;

load ../data/template/template_grid_0.5cm.mat;

[index_H,list_H]    = h_createIndexfieldtrip(template_grid.pos,'../fieldtrip-20151124/');
roi_cutoff          = 90;

index_H             = index_H(index_H(:,2) < roi_cutoff+1,:);

list_H              = list_H(1:roi_cutoff);

for nroi = 1:length(list_H)
    list_H{nroi} = ['ch' num2str(nroi)];
end

save('../data/index/MniAtlas90roi.mat','index_H','list_H');