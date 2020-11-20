clear ; clc ;

total_indx          = [];
total_list          = {};

load('../data/yctot/index/MaxCnDAudGamma.mat')
% indx_arsenal        = indx_arsenal(indx_arsenal(:,2) > 2 & indx_arsenal(:,2) < 7,:);
% list_arsenal        = list_arsenal(3:6);
% indx_arsenal(:,2)   = indx_arsenal(:,2) - 2;
total_indx          = [total_indx;indx_arsenal] ; 
total_list          = [total_list list_arsenal]; 
clear indx_arsenal list_arsenal

load('../data/yctot/index/Frontal.mat')

indx_arsenal    = indx_arsenal(indx_arsenal(:,2) == 6 | indx_arsenal(:,2) == 9 ...
    | indx_arsenal(:,2) == 16 | indx_arsenal(:,2) == 12,:);

list_arsenal    = list_arsenal([6 9 16 12]);

indx_arsenal(indx_arsenal(:,2) == 6,2)  = 5;
indx_arsenal(indx_arsenal(:,2) == 9,2)  = 6;
indx_arsenal(indx_arsenal(:,2) == 16,2) = 7;
indx_arsenal(indx_arsenal(:,2) == 12,2) = 8;

total_indx          = [total_indx;indx_arsenal] ; 
total_list          = [total_list list_arsenal]; 
clear indx_arsenal list_arsenal;

indx_arsenal = total_indx ; clear total_indx ;
list_arsenal = total_list ; clear total_list ;

save ../data/yctot/index/NewFronalAndAuditoryIndex.mat ;