clear ; clc ; addpath(genpath('../Fieldtripping/fieldtrip-20151124/')); close all;

big_index   = [];
big_list    = {};
i           = 0;

load ../data/data_fieldtrip/index/TD_BU_index.mat

slct        = [2 6 16 21 3 7 17 22 4 8 18 23 9 12 19 24];

for nroi = 1:length(slct)
    
    i           = i + 1;
    bloc        = index_H(index_H(:,2) == slct(nroi),1);
    blic        = repmat(i,length(bloc),1);
    
    big_index   = [big_index;bloc blic];
    big_list{i} = list_H{slct(nroi)};
    
end

load ../data/data_fieldtrip/index/paper_frontal_index.mat

slct        = [1 2 3 4 5 6 7 10 13 14 15 16 22 25 26];

for nroi = 1:length(slct)
    
    i           = i + 1;
    bloc        = index_H(index_H(:,2) == slct(nroi),1);
    blic        = repmat(i,length(bloc),1);
    
    big_index   = [big_index;bloc blic];
    big_list{i} = list_H{slct(nroi)};
    
end

clearvars -except big_*

index_H         = big_index ;
list_H          = big_list ;

clearvars -except *_H

save ../data/data_fieldtrip/index/PapScha.mat;