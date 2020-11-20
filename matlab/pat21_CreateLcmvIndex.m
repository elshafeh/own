clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/new.dis.lcmv.stat.mat ;

llist = 79:82;

indx_arsenal = [];

for r = 1:length(llist)
    [vox_list,vox_indx] = h_findStatMaxVoxelPerRegion(stat,0.05,llist(r),5);
    indx_arsenal = [indx_arsenal ; vox_indx repmat(r,length(vox_indx),1)];
    clear vox_list vox_indx
end

clearvars -except indx_arsenal ;

save ../data/yctot/index/lcmv.N1.DIS.mat ;