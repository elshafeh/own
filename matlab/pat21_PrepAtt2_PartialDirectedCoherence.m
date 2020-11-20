clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [2:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fprintf('Loading data & freq data for %s\n',suj);
    
    load(['../data/pe/' suj '.CnD.RamaBigCov.mat']);
    
    time_list       = [-0.6 0.2 0.6 1.4];
    chan_list       = [5:8 88:91];
    time_wind       = 0.4;
    extn_list       = {'baseline','early','late','post'};
        
    for tpoint      = 1:4
        
        cfg                             = [];
        cfg.channel                     = chan_list;
        cfg.latency                     = [time_list(tpoint) time_list(tpoint)+time_wind];
        data                            = ft_selectdata(cfg,virtsens);
        data.label                      = {'LIPS1','LIPS2','RIPS1','RIPS3','HESCL','HESCR','STGYL','STGYR'};
        
        cfg                             = [];
        cfg.order                       = 5;
        cfg.toolbox                     = 'bsmart';
        mdata                           = ft_mvaranalysis(cfg, data);
        
        cfg                             = [];
        cfg.method                      = 'mvar';
        mfreq                           = ft_freqanalysis(cfg, mdata);
        
        cfg                             = [];
        cfg.method                      = 'pdc';
        conn_pdc{tpoint,1}              = ft_connectivityanalysis(cfg, mfreq);
        
        cfg                             = [];
        cfg.method                      = 'granger';
        conn_pdc{tpoint,2}              = ft_connectivityanalysis(cfg, mfreq);
        conn_pdc{tpoint,2}.pdcspctrm    = conn_pdc{tpoint,2}.grangerspctrm;
        conn_pdc{tpoint,2}              = rmfield(conn_pdc{tpoint,2},'grangerspctrm');

        clear mfreq mdata data
        
    end
    
    fname_out               = ['../data/tfr/' suj '.CnD.RamaBigCov.4TimeWin1Pdc2Grang.mat'];
    fprintf('\nSaving %50s \n\n',fname_out);
    save(fname_out,'conn_pdc','-v7.3'); clc ;
    
    %     cfg           = [];
    %     cfg.parameter = 'pdcspctrm';
    %     cfg.xlim      = [1 150];
    %     cfg.zlim      = [0 1];
    %     ft_connectivityplot(cfg, conn_pdc{:});
    %     legend({'baseline','early','late','post'})
    
end