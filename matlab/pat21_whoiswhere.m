clear ; clc ; 

load ../data/yctot/rt/CnD_part_index.mat

for sb = 1:14
    indx_pt(indx_pt(:,1) == sb,3) = 1:length(find(indx_pt(:,1)==sb));
end

clearvars -except indx_pt

save ../data/yctot/rt/CnD_part_index.mat
