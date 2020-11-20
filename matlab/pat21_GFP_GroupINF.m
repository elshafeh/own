clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/LRNnDT.pe.mat ;

for a = 1:size(allsuj,1)
    for c = 1:size(allsuj,2)
        
        cfg                 = [];
        cfg.baseline        = [-0.2 -0.1];
        avg                 = ft_timelockbaseline(cfg,allsuj{a,c});
        cfg                 = [];
        cfg.method          = 'amplitude';
        gfp                 = ft_globalmeanfield(cfg,avg);
        gavg(a,c,:)         = gfp.avg;
        
        clear avg gfp ;

    end
end

new             = squeeze(mean(gavg,1));
inf             = mean(new(2:3,:),1);
unf             = new(1,:);
gfp_amp.avg     = [inf;unf];
gfp_amp.time    = allsuj{1,1}.time ;

plot(gfp_amp.time,gfp_amp.avg,'LineWidth',2) ;
xlim([-0.1 0.6]);
set(gca,'XAxisLocation','origin');set(gca,'fontsize',18)
set(gca,'FontWeight','bold');legend({'INF','UNF'})