clear ; clc ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   'AudViz.VirtTimeCourse.all.wav.1t90Hz.m2000p2000.mat';
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        fname_in    = ['../data/tfr/' suj '.'  lst{d} '.' ext];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        nw_chn  = [4 6];
        nw_lst  = {'audR'};
        
        for l = 1:length(nw_lst)
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.appenddim       = 'chan';
        tmp{d}              = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq ;
        
        cfg                 = [];
        cfg.baseline        = [-0.9 -0.8];
        cfg.baselinetype    = 'relchange';
        tmp{d}              = ft_freqbaseline(cfg,tmp{d});
        
        
        
        t_win               = 0.01;
        tlist               = 0:t_win:0.49;
        ftap                = 2;
        flist               = 40:ftap:88;
        
        nwspctrm            = [];
        
        for chn = 1:length(freq.label)
            for t = 1:length(tlist)
                for f = 1:length(flist)
                    
                    lmt1 = find(round(freq.time,2) == round(tlist(t),2));
                    lmt2 = find(round(freq.time,2) == round(tlist(t)+t_win,2));
                    
                    lmf1 = find(round(freq.freq) == round(flist(f)));
                    lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                    
                    data                = squeeze(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2),3));
                    data                = squeeze(mean(data,2));
                    
                    [rho,p]     = corr([allsuj_nwspctrm{:}]',[allsuj_rt{:,1}]', 'type', 'Spearman');
                    
                end
            end
        end
    end
end