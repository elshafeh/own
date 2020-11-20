clear ; clc ;

ext_data = {'123Dis.1.Dis.2.fDis.eeg.pe.mat'};

for ndata = 1
    
    load(['../data/yctot/gavg/' ext_data{ndata}]);
    
    for sb = 1:14
        
        for ndis = 1:2
            tmp{ndis}       = ft_timelockgrandaverage([],allsuj{sb,ndis,:});
        end
        
        new_suj{sb,ndata}       = tmp{1};
        new_suj{sb,ndata}.avg   = tmp{1}.avg - tmp{2}.avg; clear tmp ;
        
        cfg                 = [];
        cfg.latency         = [-0.1 1];
        new_suj{sb,ndata}   = ft_selectdata(cfg,new_suj{sb,ndata});
        
        cfg                 = [];
        cfg.baseline        = [-0.1 0];
        new_suj{sb,ndata}   = ft_timelockbaseline(cfg,new_suj{sb,ndata});
        
    end
    
    clear allsuj;
    
end

allsuj = new_suj ; clearvars -except allsuj

for ndata = 1   
    gavg{ndata} = ft_timelockgrandaverage([],allsuj{:,ndata});
end

cfg = [];
cfg.layout ='elan_lay.mat';		
cfg.xlim = [0.05 0.1];
ft_topoplotER(cfg,gavg{1});