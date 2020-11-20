clear ; clc ;

% For distractor : 100t200 and 400t500
% For target : 200t300 400t500

load ../data/yctot/stat/GammaChoose_AuditoryDisnDT.mat

llist       = [79 80 81 82];
i           = 0;

for s = [1 2 4 6]
    i   = i  + 1;
    for r = 1:length(llist)
        if r < 3
            [~,vox_indx]        = h_findStatMaxVoxelPerRegion(stat{s},0.05,llist(r),15);
        else
            [~,vox_indx]        = h_findStatMaxVoxelPerRegion(stat{s},0.05,llist(r),20);
        end
        tmp{i,r}            = [vox_indx repmat(r,length(vox_indx),1)];
        clear vox_list vox_indx
    end
end

clear ; 

indx_arsenal = [24363 1
24364 1
25684 1
24395 1
24396 1
26966 1
26967 1
25665 2
25666 2
24314 2
25603 2
25634 2
25635 2
26922 2];

list_arsenal = {'audL','audR'};

clearvars -except  indx_arsenal list_arsenal

save('../data/yctot/index/GammaAuditoryAreas.mat');