clear;

load ../data/index/broadmanAuditoryOccipital_combined.mat;

big_index_H                         = index_H(index_H(:,2) > 2,:);
big_index_H(:,2)                    = big_index_H(:,2)-2;
big_list                            = list_H(3:4);

load ../data/index/mni_frontal_rois_index.mat;

index_H(:,2)                        = index_H(:,2) + 2;
big_index_H                         = [big_index_H;index_H];
big_list                            = [big_list list_H];

index_H                             = big_index_H;
list_H                              = big_list;

clearvars -except index_H list_H

save ../data/index/broadAudMNIFront.mat
