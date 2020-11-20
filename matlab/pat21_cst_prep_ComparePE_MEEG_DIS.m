clear ; clc ; dleiftrip_addpath ;

lst_yctot = {'VN.Dis.eeg.pe','VN_DisfDis.pe'};

for cdata = 1:2
    
    load(['../data/yctot/gavg/' lst_yctot{cdata} '.mat']);
    
    for cdis = 1:2
        gavg{cdata,cdis}   = ft_timelockgrandaverage([],allsuj{:,cdis,:});
    end
    
    clear allsuj;
    
    cfg                 = [];
    cfg.parameter       = 'avg';
    cfg.operation       = 'subtract';
    gavg_diff{cdata}    = ft_math(cfg,gavg{cdata,1},gavg{cdata,2});
    
    cfg                 = [];
    cfg.baseline        = [-0.2 -0.1];
    gavg_bsl{cdata}     = ft_timelockbaseline(cfg,gavg_diff{cdata});
    
end

cfg                     = [];
cfg.layout              = 'CTF275.lay';
cfg.comment             = 'no';
cfg.marker              = 'off';
cfg.zlim                = [-60 60];
cfg.xlim                = [0.07 0.15];
figure; ft_topoplotER(cfg,gavg_bsl{2})
cfg.xlim                = [0.16 0.28];
figure; ft_topoplotER(cfg,gavg_bsl{2}) ;
cfg.xlim                = [0.29 0.37];
figure; ft_topoplotER(cfg,gavg_bsl{2}) ;

% elec_gp{1,1} = {'Fz', 'FC1', 'FCz', 'FC2', 'C3', 'C1', 'Cz', 'C2', 'CPz','C4'};
% 
% elec_gp{1,2} ={'MLT11', 'MLT12', 'MLT13', 'MLT22', 'MLT32', 'MLT42'};
% elec_gp{2,2} = {'MLO13', 'MLO14', 'MLP22', 'MLP32', 'MLP33', 'MLP34', 'MLP41', 'MLP42', ...
%     'MLP43', 'MLP44', 'MLP52', 'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLT15', 'MLT16', 'MLT26', 'MLT27'};
% elec_gp{3,2} = {'MRC17', 'MRF67', 'MRP45', 'MRP55', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', ...
%     'MRT24', 'MRT25', 'MRT35'};
% elec_gp{4,2} ={'MRT22', 'MRT23', 'MRT32', 'MRT33', 'MRT41', 'MRT42'};
% 
% for c_data = 1
%     for gp = 1
%         cfg                     = [];
%         cfg.channel             = elec_gp{gp,c_data};
%         cfg.avgoverchan         = 'yes';
%         data_slct{gp,c_data}    = ft_selectdata(cfg,gavg_bsl{c_data});
%     end
% end
% 
% close all;
% for gp = 1
%     figure;
%     plot(data_slct{gp,1}.time,data_slct{gp,1}.avg,'k','LineWidth',6) ;  xlim([-0.1 0.6]) ; ylim([-7 7])
%     vline(0,'--k');
%     set(gca,'XAxisLocation','origin')
%     set(gca,'fontsize',18)
%     set(gca,'FontWeight','bold')
% end

% cfg = [];
% cfg.xlim = [-0.1 0.6];
% cfg.ylim = [-8 8];
% cfg.layout = 'elan_lay.mat';
% cfg.channel = {'F1', 'Fz', 'F2', 'FC1', 'FCz', 'FC2', 'C1', 'Cz', 'C2'};
% ft_singleplotER(cfg,gavg_bsl{1});
%
% plot(gavg_bsl{1}.time,mean(gavg_bsl{1}.avg([5 6 7 13 14 15 22 23 24],:),1),'g','LineWidth',5) ;
% xlim([-0.1 0.7]) ; ylim([-8 8])
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold');

% close all;
% cfg                     = [];
% cfg.layout              = 'CTF275.lay';
% cfg.comment             = 'no';
% % cfg.highlightchannel    = {'F1', 'Fz', 'F2', 'FC1', 'FCz', 'FC2', 'C1', 'Cz', 'C2'};
% % cfg.highlight           = 'on';
% % cfg.highlightsymbol     = '.';
% % cfg.highlightcolor      = [1 0 0];
% % cfg.highlightsize       = 20;
% cfg.zlim                = [-60 60];
% cfg.xlim                = [0.07 0.15];
% figure; ft_topoplotER(cfg,gavg_bsl{2}) 
% cfg.xlim                = [0.22 0.26];
% figure; ft_topoplotER(cfg,gavg_bsl{2}) ;
% cfg.xlim                = [0.27 0.28];
% figure; ft_topoplotER(cfg,gavg_bsl{2}) ;
% cfg.xlim                = [0.33 0.36];
% figure; ft_topoplotER(cfg,gavg_bsl{2}) ;
% 
% % cfg.layout              = 'CTF275.lay';
% % cfg.zlim                = [-30 30];
% ft_topoplotER(cfg,gavg_bsl{2});