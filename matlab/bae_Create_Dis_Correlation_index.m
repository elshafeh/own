clear ; clc ; 

load ../data_fieldtrip/template/template_grid_0.5cm.mat

source                  = [];
source.pos              = template_grid.pos ;
source.dim              = template_grid.dim ;
source.pow              = zeros(length(source.pos),1);

[index_H,list_H]        = h_paper_cordinates_to_fieldtrip(source,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);

save('../data_fieldtrip/index/paper_frontal_index.mat','index_H','list_H');