clear ; clc ;

load ../data/yctot/gavg/D123T.pe.mat ;

cfg                     = [];
cfg.xlim                = [0.05 0.16];
cfg.layout              = 'CTF275.lay';
cfg.highlight           = 'off';
cfg.highlightchannel    =  {'MLT11', 'MLT12', 'MLT13', 'MLT22', 'MLT32', 'MLT42'};
cfg.zlim                = [-40 40];
cfg.highlightsymbol     = '.';
cfg.highlightcolor      = [0 0 0];
cfg.highlightsize       = 30;
cfg.comment             = 'no';
cfg.marker              = 'off';

ft_topoplotER(cfg,ft_timelockgrandaverage([],allsuj{:,:,:}));

for sb = 1:14
    for cdelay = 1:3
        cfg = [];
        cfg.channel         = {'MLT11', 'MLT12', 'MLT13', 'MLT22', 'MLT32', 'MLT42'};
        cfg.avgoverchan     = 'yes';
        tmp                 = ft_selectdata(cfg,allsuj{sb,cdelay});
        gavg(sb,cdelay,:)   = tmp.avg;
    end
end

clearvars -except gavg

load ../data/yctot/gavg/LRNnDT.pe.mat

for sb = 1:14
    for cdelay = 1:3
        cfg                 = [];
        cfg.channel         = {'MLT11', 'MLT12', 'MLT13', 'MLT22', 'MLT32', 'MLT42'};
        cfg.avgoverchan     = 'yes';
        tmp                 = ft_selectdata(cfg,ft_timelockgrandaverage([],allsuj{sb,:}));
        gavg(sb,4,:) = tmp.avg;
    end
end

toplot_time = allsuj{1,1}.time ;

clearvars -except gavg toplot_time

t1 = find(round(toplot_time,3) == 0.045);
t2 = find(round(toplot_time,3) == 0.18);

toplot_time = toplot_time(t1:t2);

fout            = '../txt/D123T.N1.meg.txt';
fid             = fopen(fout,'W+');
fprintf(fid,'%s\t%s\t%s\n','SUB','DELAY','latency');

cnd_list ={'D1','D2','D3','D0'};

for sb = 1:14
    for c = 1:4
        tmp     = squeeze(gavg(sb,c,t1:t2))';
        ix      = find(tmp==min(tmp));
        stmp    = toplot_time(ix);
        
        fprintf(fid,'%s\t%s\t%.4f\n',['yc' num2str(sb)],cnd_list{c},round(stmp,4));
        toboxplot(sb,c) = round(stmp,4);
    end
end

fclose(fid);

toboxplot = toboxplot(:,[4 1 2 3]);

errorbar(mean(toboxplot,1),(std(toboxplot)/sqrt(14)),'k','LineWidth',3)
set(gca,'Xtick',0:6,'XTickLabel', {'','DIS0','DIS1','DIS2','DIS3',''})
set(gca,'fontsize',18)
set(gca,'FontWeight','bold');
ylim([0.08 0.15])