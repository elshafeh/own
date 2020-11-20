clear ; clc ;

load ../data/yctot/gavg/LRNnDT.pe.mat

for cnd = 1:3
    
    gavg_erf{cnd} = ft_timelockgrandaverage([],allsuj{:,cnd});
    
    cfg                 = [];
    cfg.baseline        = [-0.2 -0.1];
    gavg_erf{cnd}       = ft_timelockbaseline(cfg,gavg_erf{cnd});
    
end

tmp{1} = gavg_erf{3};
tmp{2} = gavg_erf{2};
tmp{3} = gavg_erf{1};

gavg_erf = tmp ; 

lst_ndt{1} = {'MLO13', 'MLO14', 'MLO24', 'MLO33', 'MLO34', 'MLP34', 'MLP43', 'MLP44', 'MLP54', ...
    'MLP55', 'MLP56', 'MLT15', 'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT36', 'MLT37', 'MLT46', 'MLT47'};

lst_ndt{2} = {'MRO14', 'MRO24', 'MRO33', 'MRO34', 'MRP34', 'MRP35', 'MRP43', 'MRP44', 'MRP45', 'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT14', ...
    'MRT15', 'MRT16', 'MRT24', 'MRT25', 'MRT26', 'MRT27', 'MRT36', 'MRT37', 'MRT46', 'MRT47'};

lst_ndt{3} = {'MLT22', 'MLT23', 'MLT32', 'MLT33', 'MLT41', 'MLT42'};
lst_ndt{4} = {'MRT22', 'MRT23', 'MRT32', 'MRT33', 'MRT41', 'MRT42'};

lst_ndt{5} = {'MRP45', 'MRP55', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT24', 'MRT25', 'MRT26', 'MRT36'};
lst_ndt{6} = {'MLO14', 'MLP34', 'MLP42', 'MLP43', 'MLP44', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT15', ...
    'MLT16', 'MLT27'};


lst_chan = {'leftOcc','rightOcc','leftTemp','rightTemp'};

lst_comp = {'n1','p2','p3'};

load ../data/yctot/stat/anova.nDT.gavg&summary.mat

list_latency = [0.06 0.1; 0.18 0.08; 0.28 0.13];

% for i = 1:length(summary)
%     
%     hnt     = strsplit(summary(i).test,' ');
%     ix_chn  = find(strcmp(lst_chan,hnt{2}));
%     ix_lat  = find(strcmp(lst_comp,hnt{1}));
%     subplot(5,3,i);
%     cfg         = [];
%     cfg.xlim    = [-0.2 0.6];
%     cfg.ylim    = [-120 120];
%     cfg.channel = lst_ndt{ix_chn};
%     cfg.latency = [list_latency(ix_lat,1) list_latency(ix_lat,1)+list_latency(ix_lat,2)];
%     ft_singleplotER(cfg,gavg_erf{:});
%     legend('u','l','r')
%     title([summary(i).test ' ' num2str(summary(i).p)])
%     
% end

for i = 1:4
    
    subplot(2,2,i)
    cfg         = [];
    cfg.xlim    = [-0.2 1];
    cfg.ylim    = [-120 140];
    cfg.channel = lst_ndt{i};
    ft_singleplotER(cfg,gavg_erf{:});
    legend('r','l','u')
    
end