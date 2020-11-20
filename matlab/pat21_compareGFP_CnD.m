clear ; clc ;

ext_data = {'VN.CnD.eeg.pe.mat','new.1RCnD.2LCnD.3NCnDRT.4NCnDLT.pe.mat'};

for ndata = 1:2
    
    load(['../data/yctot/gavg/' ext_data{ndata}]);
    
    for sb = 1:14
        
        new_suj{sb,ndata}   = ft_timelockgrandaverage([],allsuj{sb,:});
        
        cfg                 = [];
        cfg.latency         = [-0.1 2];
        new_suj{sb,ndata}   = ft_selectdata(cfg,new_suj{sb,ndata});
        
        cfg                 = [];
        cfg.baseline        = [-0.1 0];
        new_suj{sb,ndata}   = ft_timelockbaseline(cfg,new_suj{sb,ndata});
        
        cfg                 = [];
        cfg.method          = 'amplitude';
        new_suj{sb,ndata}   = ft_globalmeanfield(cfg,new_suj{sb,ndata});
        
    end
    
    clear allsuj;
    
end

allsuj = new_suj ; clearvars -except allsuj

for ndata = 1:2
    gavg{ndata} = ft_timelockgrandaverage([],allsuj{:,ndata});
end

lst_data = {'EEG','MEG'};

for ndata = 1:2
    subplot(1,2,ndata)
    plot(gavg{ndata}.time,gavg{ndata}.avg,'LineWidth',5);
    xlim([-0.1 1.4]);
    vline(0,'-k');
    vline(1.2,'-k');
    title(lst_data{ndata});
end