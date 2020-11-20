clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/D123.1.Dis.2.fDis.pe.mat   

for c_delai = 1:3
    
    for c_dis = 1:2
        
        tmp{c_delai,c_dis} = ft_timelockgrandaverage([],allsuj{:,c_dis,c_delai});
        
    end
    
    cfg             = [];
    cfg.parameter   = 'avg';
    cfg.operation   = 'x1-x2';
    gavg{c_delai}   = ft_math(cfg,tmp{c_delai,1},tmp{c_delai,2});
    
    cfg                     = [];
    cfg.baseline            = [-0.1 0];
    gavg{c_delai}           = ft_timelockbaseline(cfg,gavg{c_delai});
    
end

cfg         =[];
cfg.layout  = 'CTF275.lay';
cfg.xlim    = [0.05 0.15];
ft_topoplotER(cfg,gavg{1});

% lst{1} = {'POz', 'O1', 'Oz', 'O2', 'Iz'};
% lst{2} =  {'F1', 'Fz', 'F2', 'FC1', 'FCz', 'FC2', 'C1', 'Cz', 'C2'};

lst{1} = {'MLT22', 'MLT23', 'MLT32', 'MLT33', 'MLT41', 'MLT42'};
lst{2} = {'MRO14', 'MRO24', 'MRP44', 'MRP55', 'MRP56', 'MRP57', 'MRT15', 'MRT16', 'MRT26', 'MRT27', 'MRT37'};
lst{3} = {'MLO14', 'MLO24', 'MLO34', 'MLP55', 'MLT16', 'MLT26', 'MLT27', 'MLT37'};
lst{4} = {'MRT22', 'MRT23', 'MRT32', 'MRT33', 'MRT41', 'MRT42'};


for l = 1:4
    subplot(2,2,l)
    hold on
    for cdelai = 1:3
        
        cfg             = [];
        cfg.channel     = lst{l};
        cfg.avgoverchan = 'yes';
        avMaria         = ft_selectdata(cfg,gavg{cdelai});
        plot(avMaria.time,avMaria.avg,'LineWidth',5);xlim([-0.1 0.5]);
        hline(0,'-k');
        vline(0,'-k');
    end
    legend({'D1','D2','D3'});
end
