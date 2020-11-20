clear; close all;

load('../../data/stat/alpha_emergence_sens_stat.mat')
ncue    = 1;

for ng = 1:size(stat,1)
    [min_p(ng,ncue), p_val{ng,ncue}]                = h_pValSort(stat{ng,ncue}) ;
end

figure;
i                                                   = 0;

for ng = 1:2
    for np = 1:size(p_val{ng},2)
        
        p_targ                                      =  p_val{ng}(1,np);
        
        if p_targ < 0.1
            
            lm1                                     = p_targ-0.00001;
            lm2                                     = p_targ+0.00001;
            
            stat2plot                               = h_plotStat(stat{ng,ncue},lm1,lm2);
            
            rw_plot                                 = 3;
            cl_plot                                 = 4;
            
            i                                       = i+1;
            subplot(rw_plot,cl_plot,i)
            
            cfg                                     = [];
            cfg.layout                              = 'CTF275.lay';
            cfg.comment                             = 'no';
            cfg.marker                              = 'off';
            cfg.zlim                                = 'maxabs';
            cfg.xlim                                = [0.2 0.6];
            ft_topoplotER(cfg,stat2plot);
            
            i                                       = i+1;
            subplot(rw_plot,cl_plot,i)
            
            cfg.xlim                                = [0.6 1];
            ft_topoplotER(cfg,stat2plot);
            
            cfg                                     = [];
            cfg.channel                             = stat2plot.label;
            cfg.avgoverchan                         = 'yes';
            dataplot                                = ft_selectdata(cfg,stat2plot);
            
            i                                       = i+1;
            subplot(rw_plot,cl_plot,i)
            
            plot(dataplot.freq,squeeze(nanmean(dataplot.powspctrm,3)),'LineWidth',2.5);
            xlim([5 45])
            grid;
            title('avg over time');
            
            i                                       = i+1;
            subplot(rw_plot,cl_plot,i)
            
            plot(dataplot.time,squeeze(nanmean(dataplot.powspctrm,2)),'LineWidth',2.5);
            xlim([0 1.2])
            title('avg over freq');
            
        end
    end
end