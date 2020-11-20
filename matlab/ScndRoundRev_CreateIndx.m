clear;

load /Volumes/heshamshung/Fieldtripping6Dec2018/data/index/broadAudSchTPJMniPFC.mat

new_H               = index_H(index_H(:,2) < 5,:);
new_list            = list_H(1:4);

tmp                 = index_H(index_H(:,2) == 5 | index_H(:,2) == 7 | index_H(:,2) == 9,:);
tmp(:,2)            = 5;

new_H               = [new_H;tmp]; clear tmp 
new_list{end+1}     = 'audL';

tmp                 = index_H(index_H(:,2) == 6 | index_H(:,2) == 8 | index_H(:,2) == 10,:);
tmp(:,2)            = 6;

new_H               = [new_H;tmp]; clear tmp 
new_list{end+1}     = 'audR';

tmp                 = index_H(index_H(:,2) == 11,:);
tmp(:,2)            = 7;

new_H               = [new_H;tmp]; clear tmp 
new_list{end+1}     = 'tpjL';

tmp                 = index_H(index_H(:,2) == 12,:);
tmp(:,2)            = 8;

new_H               = [new_H;tmp]; clear tmp 
new_list{end+1}     = 'tpjR';

index_H             = new_H;
list_H              = new_list;

clearvars -except index_H list_H

save ../../data/index/AudTPFC.mat