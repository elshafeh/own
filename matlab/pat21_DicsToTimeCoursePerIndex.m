clear;clc;dleiftrip_addpath;

% load('../data/yctot/stat/CnD_Gamma_m100p1100_60t100Hz_0point05.mat');
load('../data/yctot/stat/CnD_Gamma_m100p1100_60t100Hz_0point001.mat');
% load('../data/yctot/stat/NewSourceDpssStat.mat');

% tmp{1}                  = stat{1,1};
% tmp{2}                  = stat{1,2};
% stat                    = tmp;
% clear tmp ;

source                  = [];

for ntest = 1:1:length(stat)
    stat_mask           = stat{ntest}.prob < 0.05;
    tpower              = stat{ntest}.stat .* stat_mask;
    source              = [source tpower];
end

% load('../data/yctot/index/NewSourceAudVisMotor.mat')
% load('../data/yctot/index/Frontal.mat')

for l = 1:length(list_arsenal)
    avg(l,:) = nanmedian(source(indx_arsenal(indx_arsenal(:,2)==l,1),:),1);
end

figure;
for l = 1:length(list_arsenal)
    subplot(5,6,l)
    %     subplot(4,2,l)
    plot(-0.1:0.1:1,avg(l,:))
    title(list_arsenal{l});
    xlim([-0.1 1]);
    ylim([0 6])
end

% plot(-0.1:0.1:1,avg(1:6,:))


% figure;
% for l = 1:length(list_arsenal)
%     subplot(5,6,l)
%     plot([0.2 0.6],avg(l,:))
%     title(list_arsenal{l});
%     xlim([-0.1 1]);
%     ylim([-6 6])
% end