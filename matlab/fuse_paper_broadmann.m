clear ; clc ;

load ../data/index/broadmanAuditoryOccipital_combined.mat;

big_index_H                 = index_H(index_H(:,2) > 2,:);
big_index_H(:,2)            = 1;

clear index_H list_H; 

load ../data/index/paper_index_aud_occ_averaged.mat;

index_H                     = index_H(index_H(:,2) > 2,:);
index_H(:,2)                = 2;

big_index_H                 = [big_index_H;index_H];

list_H                      = {'broad_audLR','pap_audLR'};
index_H                     = big_index_H; clear big_index_H;

save ../data/index/prep21_fuse_aud_paper_broad.mat;