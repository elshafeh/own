clear ; clc ; dleiftrip_addpath ;

% load ../data/yctot/gavg/LRNnDT.pe.mat
% load ../data/yctot/gavg/nDT2RChanList.mat
% for cnd = 1:3
   
load ../data/yctot/gavg/new.1N2L3R.CnD.pe.mat

for sb = 1:size(allsuj,1)
    for cnd = 1:size(allsuj,2)
        
        allsuj_GA{sb}       = ft_timelockgrandaverage([],allsuj{sb,:});
        cfg                 = [];
        cfg.baseline        = [-0.04 0];
        allsuj_GA{sb}       = ft_timelockbaseline(cfg,allsuj_GA{sb});
        
    end
end

gavg                    = ft_timelockgrandaverage([],allsuj_GA{:,:}); clearvars -except gavg ;
cfg                     = [];
cfg.baseline            = [-0.1 0];
gavg                    = ft_timelockbaseline(cfg,gavg);

t_list = [0.15  0.21 0.29 0.33 0.41 0.48];

for t = 1:length(t_list)
    subplot(2,3,t)
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    cfg.xlim    = [t_list(t)-0.02 t_list(t)+0.02];
    cfg.zlim    = [-40 40];
    cfg.comment ='no';
    ft_topoplotER(cfg,gavg);
    title(num2str(t));
end

% figure;hold on
% plot(gavg_slct.time,gavg_slct2plot,'LineWidth',3)
% xlim([-0.1 0.6]) ;
% ylim([-20 120])
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')

% end

% list_chan{1,1}  = {'MLT11', 'MLT12', 'MLT22', 'MLT23', 'MLT24', 'MLT32', 'MLT33', 'MLT41', 'MLT42'};%N1.leftUp
% list_chan{1,2}     = {'MLO13', 'MLO14', 'MLO23', 'MLO24', 'MLO33', 'MLO34', 'MLP34', 'MLP42', 'MLP43', 'MLP44', ...
%    'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLT15', 'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT36', 'MLT37', 'MLT46', 'MLT47'};%N1.leftDown
% list_chan{1,3}      = {'MRT11', 'MRT21', 'MRT22', 'MRT23', 'MRT32', 'MRT33', 'MRT41', 'MRT42'};%N1.rightUp
% list_chan{1,4}    = {'MRO14', 'MRO24', 'MRO34', 'MRP35', 'MRP44', 'MRP45', 'MRP55', 'MRP56', 'MRP57',...
%     'MRT14', 'MRT15', 'MRT16', 'MRT25', 'MRT26', 'MRT27', 'MRT36', 'MRT37', 'MRT46'};%N1.rightDown
% 
% list_chan{2,1}       = {'MLT11', 'MLT12', 'MLT22', 'MLT23', 'MLT32', 'MLT33', 'MLT42'};%P2.leftUp
% list_chan{2,2}     = {'MLO13', 'MLO14', 'MLO23', 'MLO24', 'MLO34', 'MLP43', 'MLP54', 'MLP55', 'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT37'};%P2.leftDown
% list_chan{2,3}      = {'MRT11', 'MRT12', 'MRT13', 'MRT22', 'MRT23', 'MRT32', 'MRT33', 'MRT41', 'MRT42'};%P2.rightUp
% list_chan{2,4}    = {'MRO14', 'MRP55', 'MRP56', 'MRT15', 'MRT16', 'MRT26', 'MRT27'};%P2.rightDown
% 
% 
% list_chan{3,1}       = {'MLT11', 'MLT12', 'MLT13', 'MLT22', 'MLT32', 'MLT42'};%P3.leftUp
% list_chan{3,2}   = {'MLC54', 'MLC55', 'MLC63', 'MLO14', 'MLP11', 'MLP12', 'MLP21', 'MLP22', 'MLP23', ...
%     'MLP31', 'MLP32', 'MLP33', 'MLP34', 'MLP35', 'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT16'};% P3.centerLeft
% list_chan{3,3}  = {'MRC17', 'MRC25', 'MRF67', 'MRP35', 'MRP44', 'MRP45', 'MRP55', 'MRP56',...
%     'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT24', 'MRT25', 'MRT34', 'MRT35', 'MRT44'};%P3.centerLeft
% 
% list_name{1,1}={'N1.leftUp'};
% list_name{1,2}={'N1.leftDown'};
% list_name{1,3}={'N1.rightUp'};
% list_name{1,4}={'N1.rightDown'};
% 
% list_name{2,1}={'P2.leftUp'};
% list_name{2,2}={'P2.leftDown'};
% list_name{2,3}={'P2.rightUp'};
% list_name{2,4}={'P2.rightDown'};
% 
% list_name{3,1}={'P3.leftUp'};
% list_name{3,2}={'P3.centerLeft'};
% list_name{3,3}={'P3.centerRight'};
