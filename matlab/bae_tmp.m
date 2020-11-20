clear ; clc ; 

% load ../data_fieldtrip/index/0.5cm_LowAlphaLateWindowSourceContrast_auditory_separate.mat ; clear list_H ;
%
% index_H(index_H(:,2) == 2,2) = 2 ;
% index_H(index_H(:,2) == 4,2) = 2 ;
% index_H(index_H(:,2) == 1,2) = 1 ;
% index_H(index_H(:,2) == 3,2) = 1 ;
% list_H                        = {'audL','audR'};
% save ../data_fieldtrip/index/NewAudLR_for_WholeBrainConnectivity.mat ;

load ../data_fieldtrip/index/0.5cm_NewHighAlphaLateWindowAgeContrast11Rois.mat ;

index_H = index_H(index_H(:,3) < 83 & index_H(:,3) > 78,[1 3]) ;

index_H(index_H(:,2) == 79,2) = 1 ;
index_H(index_H(:,2) == 81,2) = 1 ;
index_H(index_H(:,2) == 80,2) = 2 ;
index_H(index_H(:,2) == 82,2) = 2 ;

list_H                        = {'audL','audR'};

save ../data_fieldtrip/index/AgeContrast_NewAudLR_for_WholeBrainConnectivity.mat ;