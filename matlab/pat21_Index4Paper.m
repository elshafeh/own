clear; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/NewSourceDpssStat.mat

% Auditory ROIs

llist = 1:2;

indx_arsenal = [];

for r_list = 1:length(llist)
    [vox_list,vox_indx] = h_findStatMaxVoxelPerRegion(stat{1,2},0.05,llist(r_list),5);
    indx_arsenal        = [indx_arsenal ; vox_indx repmat(r_list,length(vox_indx),1)];
    clear vox_list vox_indx
end

clearvars -except stat indx_arsenal ; clc ; 

% Visual ROIs

% cond = {'left','right'};
% 
% for c = 1:2
%     [vox_list{c} , vox_indx] = h_findStatMaxVoxel(stat{2,2},0.05,5,cond{c}); clc ;
%     indx_arsenal = [indx_arsenal ; vox_indx repmat(c,length(vox_indx),1)];
% end
% 
% indx_arsenal = sortrows(indx_arsenal,2);

clearvars -except indx_arsenal ; clc ;

list_arsenal = {'maxPreL','maxPreR'};

save ../data/yctot/index/NewSourceMotorIndex.mat ;