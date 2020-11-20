clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    lst_cnd     = {''};
    
    for cnd = 1
        
        ext1        =   [lst_cnd{cnd} 'nDT.AudViz.VirtTimeCourse'];
        fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t90Hz.m2000p2000.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        nw_chn              = [3 5;4 6];
        nw_lst              = {'audL','audR'};
        
        for l = 1:size(nw_chn,1)
            
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
            
        end
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';
        cfg.appenddim   = 'chan';
        allsuj{sb,cnd}  = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
    end
    
end

clearvars -except allsuj;

gavg = ft_freqgrandaverage([],allsuj{:,1});

for chn = 1:2
    subplot(2,1,chn)
    cfg = [];
    cfg.xlim = [-0.2 0.8];
    cfg.ylim = [7 15];
    cfg.zlim = [-0.3 0.3];
    cfg.channel = chn;
    ft_singleplotTFR(cfg,gavg);
end