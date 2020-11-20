clear;clc;dleiftrip_addpath;

% load('../data/yctot/stat/CnD_Gamma_m100p1100_60t100Hz_0point05.mat');
load('../data/yctot/stat/CnD_Gamma_m100p1100_60t100Hz_0point001.mat');

source      = [];

for ntest = 1:1:length(stat)
    stat_mask        = stat{ntest}.prob < 0.05;
    tpower           = stat{ntest}.stat .* stat_mask;
    source           = [source tpower];
end

llist       = [79 80 81 82];
chn_list    = {'HGL','HGR','STGL','STGR'};
indx        = h_createIndexfieldtrip;
indxAud     = [];

for l = 1:length(llist)
    tmp     = indx(indx(:,2) == llist(l),1);
    indxAud = [indxAud; tmp repmat(l,length(tmp),1)];
    clear tmp;
end

for l = 1:length(chn_list)
    avg(l,:) = nanmean(source(indxAud(indxAud(:,2)==l,1),:),1);
end

figure;
hold on;

for l = 1:length(chn_list)
    plot(-0.1:0.1:1,avg(l,:))
end