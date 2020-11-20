clear ; clc ;

% load ../data/yctot/gavg/VN_DisfDis.pe.mat
load ../data/yctot/gavg/LRNnDT.pe.mat

% gavg            = ft_timelockgrandaverage([],allsuj{:,1,:});
gavg            = ft_timelockgrandaverage([],allsuj{:,:});

cfg=[];
cfg.baseline = [-0.2 -0.1];
gavg = ft_timelockbaseline(cfg,gavg);

% fgavg           = ft_timelockgrandaverage([],allsuj{:,2,:});

cfg = [];
cfg.method      = 'amplitude';
gfp_amp         = ft_globalmeanfield(cfg, gavg);

% fgfp_amp        = ft_globalmeanfield(cfg, fgavg);
% nw_gfp = gfp_amp.avg-fgfp_amp.avg;

% tbsl            = [find(round(gavg.time,3) == -0.2) find(round(gavg.time,3) == -0.1)];
% gfp_bsl         = mean(nw_gfp(1,tbsl(1):tbsl(2)));
% nw_gfp          = nw_gfp - gfp_bsl;

plot(gfp_amp.time,gfp_amp.avg,'b','LineWidth',5) ;  xlim([-0.1 0.6]) ;
vline(0,'--k');
set(gca,'XAxisLocation','origin')
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')

% for d = 1:2
%     gavg{d}            = ft_timelockgrandaverage([],allsuj{:,d,:});
%     cfg.method         = 'amplitude';
%     gfp_amp{d}         = ft_globalmeanfield(cfg, gavg{d});
%     tbsl               = [find(round(gavg{d}.time,3) == -0.2) find(round(gavg{d}.time,3) == -0.1)];
%     gfp_bsl             = mean(gfp_amp{d}.avg(1,tbsl(1):tbsl(2)));
%     gf_toplot(d,:)     = (gfp_amp{d}.avg - gfp_bsl) ./ (gfp_bsl);
% end
% 
% figure;
% plot(gfp_amp{1}.time,gf_toplot) ;  xlim([-0.1 0.6]) ;
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% 
% for sb = 1:14
%     gavg{sb}            = ft_timelockgrandaverage([],allsuj{sb,1,:});
%     cfg                 = [];
%     cfg.method          = 'amplitude';
%     gfp_amp{sb}         = ft_globalmeanfield(cfg, gavg{sb});
%     tbsl                = [find(round(gavg{sb}.time,3) == -0.2) find(round(gavg{sb}.time,3) == -0.1)];
%     gfp_bsl             = mean(gfp_amp{sb}.avg(1,tbsl(1):tbsl(2)));
%     gf_toplot(sb,:)     = (gfp_amp{sb}.avg - gfp_bsl) ./ (gfp_bsl);
%         gf_toplot(sb,:)     = gfp_amp{sb}.avg;
% end
% 
% figure;
% plot(gfp_amp{1}.time,gf_toplot(1:7,:)) ;  xlim([-0.1 0.3]) ;
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% figure;
% plot(gfp_amp{1}.time,gf_toplot(8:end,:)) ;  xlim([-0.1 0.3]) ;
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% 
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')
% 
% plot(gfp_amp.time,gfp_amp.avg)
% legend({'nDT'});
% xlim([-0.1 0.6]);
% 
% load ../data/yctot/gavg/Concat_DisfDis.pe.mat
% 
% for n = 1:size(allsuj,2)
% 
%     gavg{n}             = ft_timelockgrandaverage([],allsuj{:,n});
% 
%     cfg                 = [];
%     cfg.method          = 'amplitude';
%     gfp_amp{n}          = ft_globalmeanfield(cfg, gavg{n});
% 
%         tbsl                = [find(round(gavg{n}.time,3) == -0.2) find(round(gavg{n}.time,3) == -0.1)];
%         gfp_bsl             = mean(gfp_amp{n}.avg(1,tbsl(1):tbsl(2)));
%         gfp_amp{n}.avg      = (gfp_amp{n}.avg - gfp_bsl) ./ (gfp_bsl);
% 
% end
% 
% plot(gfp_amp{1}.time,gfp_amp{1}.avg-gfp_amp{2}.avg)
% 
% tbsl                = [find(round(gavg.time,3) == -0.2) find(round(gavg.time,3) == -0.1)];
% gfp_bsl             = mean(gfp_amp.avg(1,tbsl(1):tbsl(2)));
% gfp_amp.avg         = (gfp_amp.avg - gfp_bsl) ./ (gfp_bsl);
% 
% plot(gfp_amp.time,gfp_amp.avg,'g','LineWidth',5) ;  xlim([-0.1 0.6]) ;
% vline(0,'--k');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')