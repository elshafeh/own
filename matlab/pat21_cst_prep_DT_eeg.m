clear ; clc ; 

load ../data/yctot/gavg/D123T.eeg.pe.mat ;

for sb = 1:14
    for cdelay = 1:3
        gavg(sb,cdelay,:) = allsuj{sb,1,cdelay}.avg(23,:);
    end
end

clearvars -except gavg

load ../data/yctot/gavg/VN.nDT.eeg.pe.mat

for sb = 1:14
    tmp = [allsuj{sb,1}.avg(23,:);allsuj{sb,2}.avg(23,:)];
    gavg(sb,4,:) = mean(tmp,1);
    clear tmp;
end

toplot_time = allsuj{1,1}.time ;

clearvars -except gavg toplot_time

% plot(toplot_time,squeeze(mean(gavg,1)),'LineWidth',5) ;
% xlim([-1 1]);
% legend('D1','D2','D3','D0')
% ylim([-12 12]);
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold');

t1 = find(round(toplot_time,3) == 0.05);
t2 = find(round(toplot_time,3) == 0.16);

toplot_time = toplot_time(t1:t2);

fout            = '../txt/D123T.N1.eeg.txt';
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

clearvars -except toboxplot

toboxplot = toboxplot(:,[4 1 2 3]);

errorbar(mean(toboxplot,1),(std(toboxplot)/sqrt(14)),'k','LineWidth',3)
set(gca,'Xtick',0:6,'XTickLabel', {'','DIS0','DIS1','DIS2','DIS3',''})
set(gca,'fontsize',18)
set(gca,'FontWeight','bold');
ylim([0.08 0.15])

load ../data/yctot/gavg/D123T.eeg.pe.mat ;

cfg                     = [];
cfg.xlim                = [0.05 0.16];
cfg.layout              = 'elan_lay.mat';
cfg.highlight           = 'on';
cfg.highlightchannel    =  'Cz';
cfg.zlim                = [-10 10];
cfg.highlightsymbol     = '.';
cfg.highlightcolor      = [0 0 0];
cfg.highlightsize       = 60;
cfg.comment             = 'no';
ft_topoplotER(cfg,ft_timelockgrandaverage([],allsuj{:,:,:}));