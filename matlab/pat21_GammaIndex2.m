clear ; clc ;

load ../data/yctot/stat/GammaChoose_VisualAreasCnD.mat

tmp = [];

llist = [43 44 49:54];

for r_list = 1:length(llist)
    [~,vox_indx]        = h_findStatMaxVoxelPerRegion(stat,0.05,llist(r_list),5);
    tmp                 = [tmp ; vox_indx repmat(r_list,length(vox_indx),1)];
    clear vox_list vox_indx
end

indx_arsenal = tmp ;
list_arsenal = {'calcL','calcR','occSupL','occSupR','occMidL','occMidR','occInfL','occInfR'};

clearvars -except  indx_arsenal list_arsenal

save('../data/yctot/index/GammaVisualAreas.mat');