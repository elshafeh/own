clear ; clc ; dleiftrip_addpath ;

% for sb = 1:14
%
%     suj_list = [1:4 8:17];
%
%     suj = ['yc' num2str(suj_list(sb))];
%
%     fname = ['../data/' suj '/elan/' suj '.CnD.eeg.mat'];
%     fprintf('Loading %30s\n',fname);
%     load(fname);
%
%     avg{sb} = ft_timelockanalysis([],data_elan);
%
%     clear data_elan
%
% end
%
% Gavg = ft_timelockgrandaverage([],avg{:}) ;
%
% clearvars -except Gavg avg ; save ../data/yctot/gavg/eeg_timelock.mat ;

load ../data/yctot/gavg/eeg_timelock.mat ;

cfg             = [];
cfg.lpfilter    = 'yes';
cfg.lpfreq      = 20;
Gavg_lp         = ft_preprocessing(cfg,Gavg);

cfg             = [];
cfg.baseline    = [-0.1 0];
Gavg_lp_bsl     = ft_timelockbaseline(cfg,Gavg_lp);

cfg         = [];
cfg.layout  = 'elan_lay.mat';
cfg.zlim    = [-3 3];
cfg.xlim    = [0 0.2];
cfg.showlabels = 'yes';
ft_topoplotER(cfg,Gavg_lp_bsl);

figure;
cfg         = [];
cfg.layout  = 'elan_lay.mat';
cfg.zlim    = [-3 3];
cfg.xlim    = [-2 2];
cfg.showlabels = 'yes';
ft_multiplotER(cfg,Gavg_lp_bsl);