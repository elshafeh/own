clear ; clc ; 

new_list = {};
new_indx = [];

load ../data_fieldtrip/index/broadmanAuditoryOccipital_Separate.mat

new_list        = [new_list list_H(7:12)];
index_H         = index_H(index_H(:,2) > 6,:);
index_H(:,2)    = index_H(:,2) - 6;

new_indx        = [new_indx;index_H]; clear index_H list_H ; 

load ../data_fieldtrip/index/TD_BU_index.mat

for n = 1:length(list_H)
    list_H{n} = list_H{n}(11:end);
end

new_list        = [new_list list_H];
index_H(:,2)    = index_H(:,2) + 6;

new_indx        = [new_indx;index_H]; clear index_H list_H ; 

load ../data_fieldtrip/index/paper_frontal_index.mat

new_list        = [new_list list_H'];
index_H(:,2)    = index_H(:,2) + 33;

new_indx        = [new_indx;index_H]; clear index_H list_H ; 

index_H         = new_indx ;
list_H          = new_list ;

save('../data_fieldtrip/index/AudBroadSchaefFront.mat','index_H','list_H');