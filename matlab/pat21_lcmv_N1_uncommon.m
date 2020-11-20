clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/new.dis.lcmv.stat.mat

tmp{1} = stat ; clear stat 

load ../data/yctot/stat/nDT.lcmv.stat.mat ; 

tmp{2} = stat{1} ; clear stat ; stat = tmp ; clear tmp ;

for n = 1:2
    stat{n}.mask      = stat{n}.prob < 0.05;
    stat{n}.stat      = stat{n}.stat .* stat{n}.mask;
    list{n}           = FindSigClusters(stat{n},0.05);
end

dis_unique = {};
tar_unique = {};

for n = 1:length(list{1})
    
    x = list{1}{n,1};
    y = find(strcmp(list{2}(:,1),x));

    if isempty(y)
        dis_unique{end+1,1} = x; 
    end
    
end

for n = 1:length(list{2})
    
    x = list{2}{n,1};
    y = find(strcmp(list{1}(:,1),x));

    if isempty(y)
        tar_unique{end+1,1} = x; 
    end
    
end