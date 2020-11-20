clear ; clc ; dleiftrip_addpath;

tpsm = 1;

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
    
    lst_chan = {{'maxLO','maxRO'},{'maxHL','maxSTL'}};
    
    lst_freq{1}    = 12:15;
    lst_freq{2}    = 8:11;
    
    twin        = 0.4;
    
    t_list = 0.6:twin:0.9;
    
    for x = 1:2
        for t = 1:length(t_list)
            cfg                                 = [];
            cfg.channel                         = lst_chan{x};
            cfg.latency                         = [t_list(t) t_list(t)+twin];
            cfg.frequency                       = [lst_freq{x}(1) lst_freq{x}(end)];
            cfg.avgovertime                     = 'yes';
            cfg.avgoverfreq                     = 'yes';
            cfg.avgoverchan                     = 'yes';
            data                                = ft_selectdata(cfg,freq);
            big_data(sb,x,t)                    = data.powspctrm ;
        end
    end
    
end

clearvars -except big_data

for x = 1:size(big_data,3)
    for y = 1:size(big_data,3)
        
        a = squeeze(big_data(:,1,x));
        b = squeeze(big_data(:,2,y));

        [rho(x,y), p(x,y)] = corr(a,b, 'type', 'Pearson');
        
        clear a b
        
    end
end

mask    = rho < 0 ;
p_msk   = mask .* p ;