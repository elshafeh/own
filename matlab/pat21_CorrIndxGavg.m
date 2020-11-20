clear ; clc ;

tpsm = 1 ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    load(['../data/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'])
    
    cfg                 = [];
    cfg.avgoverrpt      = 'yes';
    freq                = ft_selectdata(cfg,freq);
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg,freq);
    
    lst_chan = {{'maxLO','maxRO'},{'maxHL','maxSTL','maxHR','maxSTR'}};
    lst_time{1} = [0.9 1.1];
    lst_time{2} = [0.9 1.1];
    lst_freq    = [13 9];
    
    for x = 1:2
        cfg                                 = [];
        cfg.channel                         = lst_chan{x};
        cfg.latency                         = lst_time{x};%[0.6 1];
        cfg.frequency                       = [lst_freq(x)-tpsm lst_freq(x)+tpsm];
        cfg.avgovertime                     = 'yes';
        cfg.avgoverfreq                     = 'yes';
        cfg.avgoverchan                     = 'yes';
        data                                = ft_selectdata(cfg,freq);
        big_data(x)                         = data.powspctrm ;
    end
    
    clc;
    
    load '../data/yctot/rt/rt_cond_classified.mat';
    
    dataOcc             = big_data(1);
    dataAud             = big_data(2);
    
    dataMean            = mean([dataOcc dataAud],2);
    
    corrIndex(sb,1)     = (dataAud-dataOcc)./(dataMean);
    %     corrIndex(sb,y)     = (dataOcc-dataAud)./(dataAud);
    
    %     corrIndex(sb,1)     = (dataAud-dataOcc)./(dataAud+dataOcc);
    
    RTindex(sb,1)     = mean(rt_all{sb});
    RTindex(sb,2)     = median(rt_all{sb});
    
    
    clearvars -except sb corrIndex RTindex tpsm
    
end
  
[rho_mean,p_mean]  = corr(corrIndex(:,1),RTindex(:,1), 'type', 'Spearman');
[rho_median,p_median]  = corr(corrIndex(:,1),RTindex(:,2), 'type', 'Spearman');