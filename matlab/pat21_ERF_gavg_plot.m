clear ; clc ;

load ../data/yctot/gavg/LRNnDT.pe.mat ;

for sb = 1:14
        allsuj_GA{sb} = ft_timelockgrandaverage([],allsuj{sb,:});
end

gavg = ft_timelockgrandaverage([],allsuj_GA{:,:});

cfg                 = [];
cfg.baseline        = [-0.2 -0.1];
gavg_bsl            = ft_timelockbaseline(cfg,gavg);

figure ; plot(gavg.time,gavg_bsl.avg(indx,:)); xlim([-0.05 1]);

clearvars -except gavg gavg_bsl; 

lst_ndt{1} = {'MLO13', 'MLO14', 'MLO24', 'MLO33', 'MLO34', 'MLP34', 'MLP43', 'MLP44', 'MLP54', ...
    'MLP55', 'MLP56', 'MLT15', 'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT36', 'MLT37', 'MLT46', 'MLT47'};

lst_ndt{2} = {'MRO14', 'MRO24', 'MRO33', 'MRO34', 'MRP34', 'MRP35', 'MRP43', 'MRP44', 'MRP45', 'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT14', ...
    'MRT15', 'MRT16', 'MRT24', 'MRT25', 'MRT26', 'MRT27', 'MRT36', 'MRT37', 'MRT46', 'MRT47'};

lst_ndt{3} = {'MLT22', 'MLT23', 'MLT32', 'MLT33', 'MLT41', 'MLT42'};
lst_ndt{4} = {'MRT22', 'MRT23', 'MRT32', 'MRT33', 'MRT41', 'MRT42'};

indx = [];

for n = 1:4
    indx = [indx;h_indx_tf_labels(lst_ndt{n})'];
end

% lst_ndt{5} = {'MRP45', 'MRP55', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT24', 'MRT25', 'MRT26', 'MRT36'};
% lst_ndt{6} = {'MLO14', 'MLP34', 'MLP42', 'MLP43', 'MLP44', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT15', ...
%     'MLT16', 'MLT27'};


% for l = 1:6
%     cfg=[];
%     cfg.avgoverchan = 'yes';
%     cfg.channel = lst_ndt{l};
%     gavg_slct{l} = ft_selectdata(cfg,gavg);
%     gavg_avg(l,:) = gavg_slct{l}.avg;
% end

% figure;
% hold on;
% rectangle('Position',[0.07 -180 0.08 360],'FaceColor',[0.5 0.5 0.5],'EdgeColor','k');
% rectangle('Position',[0.21 -180 0.07 360],'FaceColor',[0.7 0.7 0.7],'EdgeColor','k')
% rectangle('Position',[0.29 -180 0.05 360],'FaceColor',[0.9 0.9 0.9],'EdgeColor','k')
% plot(gavg.time,gavg_bsl.avg);
% xlim([-0.1 0.6]);
% ylim([-180 180]);
% set(gca,'FontSize',20,'Fontweight','bold')

list_lat = 0:0.05:0.2;

for l = 1:length(list_lat)
    figure;
    cfg.xlim    = [list_lat(l) list_lat(l)+0.05];
    cfg.zlim    = [-45 45];
    cfg.layout  = 'CTF275.lay';
    ft_topoplotER(cfg,gavg_bsl);
end

% [0.06 -180 0.1 360]
% [0.18 -180 0.08 360]
% [0.28 -180 0.13 360]
