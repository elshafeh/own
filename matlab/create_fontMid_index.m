clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

load ../data/template/template_grid_0.5cm.mat
load ../data/index/FrontalRegionsCombined.mat;

source.pos                      = template_grid.pos;
source.dim                      = template_grid.dim;

list_roi                        = 5:6;

exit_H{1}                       = [list_H{5} '_slct'];
exit_H{2}                       = [list_H{6} '_slct'];

exit_index                      = [];

for nroi = 1:length(list_roi)
    
    source.pow                          = nan(length(template_grid.pos),1);
    vinterest                           = index_H(index_H(:,2) == list_roi(nroi),1);
    vinterest                           = [vinterest source.pos(vinterest,2)];
    
    vinterest                           = vinterest(vinterest(:,2) > 3,1);
    
    exit_index                          = [exit_index; vinterest repmat(nroi,length(vinterest),1)];
    
end

list_H      = exit_H;
index_H     = exit_index;

clearvars -except list_H index_H ;

save ../data/index/frontmidselectindex.mat;