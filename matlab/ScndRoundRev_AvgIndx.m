clear;

load ../../data/index/AudTPFC.mat

ix              = 0;
new_index       = [];

for nroi = 1:2:7    
    ix          = ix+1;
    tmp         = index_H(index_H(:,2) == nroi | index_H(:,2) == nroi+1,:);
    tmp(:,2)    = ix;
    new_index   = [new_index;tmp];clear tmp;
end

list_H          = {'vlpfc','dlpfc','acx','tpj'};
index_H         = new_index;

clearvars -except list_H index_H

save ../../data/index/AudTPFCAveraged.mat
