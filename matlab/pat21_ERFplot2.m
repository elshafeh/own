clear ; clc ;

load ../data/yctot/gavg/LRNnDT.pe.mat ;

for sb = 1:14
    allsuj_GA{sb}       = ft_timelockgrandaverage([],allsuj{sb,:});
    cfg                 = [];
    cfg.baseline        = [-0.2 -0.1];
    allsuj_GA{sb}       = ft_timelockbaseline(cfg,allsuj_GA{sb});
    gavg(sb,:,:)        = allsuj_GA{sb}.avg;
end


lst_ndt{1} = {'MLO13', 'MLO14', 'MLO24', 'MLO33', 'MLO34', 'MLP34', 'MLP43', 'MLP44', 'MLP54', ...
    'MLP55', 'MLP56', 'MLT15', 'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT36', 'MLT37', 'MLT46', 'MLT47'};

lst_ndt{2} = {'MRO14', 'MRO24', 'MRO33', 'MRO34', 'MRP34', 'MRP35', 'MRP43', 'MRP44', 'MRP45', 'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT14', ...
    'MRT15', 'MRT16', 'MRT24', 'MRT25', 'MRT26', 'MRT27', 'MRT36', 'MRT37', 'MRT46', 'MRT47'};

lst_ndt{3} = {'MLT22', 'MLT23', 'MLT32', 'MLT33', 'MLT41', 'MLT42'};
lst_ndt{4} = {'MRT22', 'MRT23', 'MRT32', 'MRT33', 'MRT41', 'MRT42'};

indx = [];

for n = 1:4
    indx{n} = h_indx_tf_labels(lst_ndt{n});
end

figure;
hold on;
for sb = 1:14
    for n = 1:4
        plot(allsuj{1,1}.time,mean(squeeze(gavg(sb,indx{n},:)))); xlim([0 0.2]);
    end
end
hold off