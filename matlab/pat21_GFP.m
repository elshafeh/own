clear ; clc ; dleiftrip_addpath ;

% load ../data/yctot/gavg/new.1N2L3R4all.bp.pe.mat ;
% load ../data/yctot/gavg/new.1pull2push.bp.pe.mat
% load ../data/yctot/gavg/new.1N2L3R.CnD.pe.mat

load ../data/yctot/gavg/new.1RCnD.2LCnD.3NCnDRT.4NCnDLT.pe.mat

for sb = 1:size(allsuj,1)
    
    %     allsuj{sb,4} = ft_timelockgrandaverage([],allsuj{sb,2:3}); % Vcue
    %     allsuj{sb,5} = ft_timelockgrandaverage([],allsuj{sb,1:3}); % Allcue
    
    for cnd = 1:size(allsuj,2)
        
        cfg                 = [];
        cfg.baseline        = [-0.1 0];
        avg                 = ft_timelockbaseline(cfg,allsuj{sb,cnd});
        
        cfg                 = [];
        cfg.method          = 'amplitude';
        gfp                 = ft_globalmeanfield(cfg,avg);
        gavg(sb,cnd,:)      = gfp.avg;
        
        clear avg gfp ;
        
    end
end

gfp_amp.avg     = squeeze(mean(gavg,1));
gfp_amp.time    = allsuj{1,1}.time ;

plot(gfp_amp.time,gfp_amp.avg,'LineWidth',2) ;
xlim([-0.1 1.2]) ;
set(gca,'XAxisLocation','origin');set(gca,'fontsize',18)
set(gca,'FontWeight','bold');
legend({'RCnD','LCnD','NCnDRT','NCnDLT'})
vline(0,'--k');