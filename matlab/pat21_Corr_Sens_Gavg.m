clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/LRNnDT.pe.mat
load ../data/yctot/rt/rt_CnD_adapt.mat

pre_bsl = allsuj ;

for sb = 1:14
    
    suj_list            = [1:4 8:17];
    suj                 = ['yc' num2str(suj_list(sb))];
    allsuj_GA{sb,1}     = ft_timelockgrandaverage([],pre_bsl{sb,:});
    
    twin                = 0.135;
    tlist               = 0.05;
    
    nw_avg = [];
    
    for t = 1:length(tlist);
        
        lmt1        = find(round(allsuj_GA{sb,1}.time,2)==round(tlist(t),2));
        lmt2        = find(round(allsuj_GA{sb,1}.time,2)==round(tlist(t)+twin,2));
        nw_avg(:,t) = mean(allsuj_GA{sb,1}.avg(:,lmt1:lmt2),2);
        
    end
    
    allsuj_GA{sb,1}.avg     = nw_avg;
    allsuj_GA{sb,1}.time    = tlist;
    allsuj_rt{sb,1}         = median(rt_all{sb});
    allsuj_rt{sb,2}         = mean(rt_all{sb});
    
end

clearvars -except allsuj_*

[design,neighbours]     = h_create_design_neighbours(14,'meg','t');

cfg                     = [];
cfg.method              = 'montecarlo';

cfg.statistic           = 'ft_statfun_correlationT'; 

cfg.clusterstatistics   = 'maxsum';cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;    
cfg.minnbchan           = 4;cfg.tail                = 0;
cfg.clustertail         = 0;cfg.alpha               = 0.025;cfg.numrandomization    = 1000;cfg.neighbours          = neighbours;
cfg.ivar                = 1;

lst_tst = {'Pearson','Spearman'};

for x = 2
    for y = 2
        cfg.design (1,1:14)     = [allsuj_rt{:,y}];
        cfg.type                = lst_tst{x};
        stat{x,y}               = ft_timelockstatistics(cfg, allsuj_GA{:});
        [min_p(x,y),p_val{x,y}] = h_pValSort(stat{x,y});
    end
end

for x = 2
    for y = 2
        stat2plot{x,y}               = h_plotmyERFstat(stat{x,y},0.05);
    end
end

for x = 2
    for y = 2
        figure;
        cfg             = [];
        %         cfg.xlim        = tlist;
        cfg.zlim        = [-4 4];
        cfg.layout      = 'CTF275.lay';
        ft_topoplotER(cfg,stat2plot{x,y})
    end
end

N1RTChan = {'MRC16', 'MRC17', 'MRC24', 'MRC25', 'MRC31', 'MRC32', 'MRF67', ...
    'MRO14', 'MRP23', 'MRP34', 'MRP35', 'MRP42', 'MRP43', 'MRP44', 'MRP45', ...
    'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT26'};


N1RTChan = h_indx_tf_labels(N1RTChan);

for sb = 1:14
    x(sb,1) = mean(allsuj_GA{sb}.avg(N1RTChan));
    y(sb,1) = allsuj_rt{sb,2};
end

scatter(x,y,'filled','LineWidth',20);
h =lsline;
ylabel('Reaction Time');
xlabel('N1 Amplitude');
set(h, 'linewidth',2,'color','b')
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')

% for x = 1:2
%     for y = 1:2
%         stat{x,y} = rmfield(stat{x,y},'cfg');
%     end
% end

avg = ft_timelockgrandaverage([],allsuj_GA{:});
cfg             = [];
cfg.layout      = 'CTF275.lay';
cfg.comment     = 'no';
cfg.marker      = 'off';
ft_topoplotER(cfg,avg)