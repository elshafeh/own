clear ; clc ; 

index_tot       = [];
list_tot        = {};

load ../data_fieldtrip/index/allYc_1Max4Neigh_high_alpha_occipital.mat

index_tot       = [index_tot; index_H];
list_tot        = [list_tot list_H];

load ../data_fieldtrip/index/allYc_1Max4Neigh_low_alpha_auditory.mat

index_H(:,2)    = index_H(:,2) + 2;
index_tot       = [index_tot; index_H];
list_tot        = [list_tot list_H];

index_H         = index_tot;
list_H          = list_tot;

save('../data_fieldtrip/index/allYc_1Max4Neigh_low_combined.mat','index_H','list_H');

