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
    
    %     lst_chan = {{'maxLO','maxRO'},{'maxRO'},{'maxLO'} ...
    %         {'maxHL','maxSTL'},{'maxHR','maxSTR'},{'maxHL','maxSTL','maxHR','maxSTR'}};
    
    lst_freq    = [9 13];
    
    t_list = 
    
    for c_chan = 1:length(lst_chan)
        for c_freq = 1:2
            for t = 1:length(t_list)
                cfg                                 = [];
                cfg.channel                         = lst_chan{c_chan};
                cfg.latency                         = [0.7 0.8];
                cfg.frequency                       = [lst_freq(c_freq)-tpsm lst_freq(c_freq)+tpsm];
                cfg.avgovertime                     = 'yes';
                cfg.avgoverfreq                     = 'yes';
                cfg.avgoverchan                     = 'yes';
                data                                = ft_selectdata(cfg,freq);
                big_data(c_chan,c_freq)             = data.powspctrm ;
            end
        end
    end
    
    clc;
    
    lst_chan_compare = [1 2];
    
    for y = 1:size(lst_chan_compare,1)
        dataOcc(sb,y)     = squeeze(big_data(lst_chan_compare(y,1),2));
        dataAud(sb,y)     = squeeze(big_data(lst_chan_compare(y,2),1));        
    end
    
    clearvars -except sb dataAud dataOcc tpsm
    
end

for y = 1:size(dataOcc,2)
    [rho(y),p(y)]  = corr(dataOcc(:,y),dataAud(:,y), 'type', 'Spearman');
end

cop2past = [p;rho];