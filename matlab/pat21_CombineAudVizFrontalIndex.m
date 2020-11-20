clear ; clc ;

total_indx  = [];
total_list  = {};

load ../data/yctot/index/GammaVisualAreas.mat; 

indx_arsenal(mod(indx_arsenal(:,2),2) ~= 0,2) = 1;
indx_arsenal(mod(indx_arsenal(:,2),2) == 0,2) = 2;
indx_arsenal = sortrows(indx_arsenal,2);

total_indx = [total_indx;indx_arsenal] ; total_list{1} = 'occL'; total_list{2} = 'occR'; 

clear indx_arsenal list_arsenal

load ../data/yctot/index/GammaAuditoryAreas.mat; 

indx_arsenal(:,2)   = indx_arsenal(:,2) + 2;
total_indx          = [total_indx;indx_arsenal] ; total_list = [total_list list_arsenal]; clear indx_arsenal list_arsenal

load ../data/yctot/index/Frontal.mat; 

indx_arsenal(:,2)   = indx_arsenal(:,2) + 4;
total_indx          = [total_indx;indx_arsenal] ; total_list = [total_list list_arsenal]; clear indx_arsenal list_arsenal

indx_arsenal = total_indx ; clear total_indx ;
list_arsenal = total_list ; clear total_list ;

save ../data/yctot/index/AudVizFrontal4Gamma.mat ;