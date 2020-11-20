clear ; clc ;

load ../data_fieldtrip/index/0.5cm_LowAlphaLateWindowSourceContrast_auditory_separate.mat

index_H(index_H(:,2) == 1 | index_H(:,2) == 3,2) = 20;
index_H(index_H(:,2) == 2 | index_H(:,2) == 4,2) = 10;

index_H(:,2) = index_H(:,2)/10 ;

index_H = index_H(index_H(:,2) ==1,:);

list_H = {'audR'};

save ../data_fieldtrip/index/0.5cm_LowAlphaLateWindowSourceContrast_auditory_separate_then_averaged.mat
