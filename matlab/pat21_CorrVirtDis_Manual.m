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
        
    end
    
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.operation       = 'subtract';
    freq                = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
    
    cfg                                 = [];
    cfg.baseline                        = [-0.2 -0.1];
    cfg.baselinetype                    = 'absolute';
    freq                                = ft_freqbaseline(cfg,freq);
    
    t_win               = 0.1;
    tlist               = 0.25;
    ftap                = 15;
    flist               = 35;
    
    for chn = 1:length(freq.label)
        for t = 1:length(tlist)
            for f = 1:length(flist)
                
                lmt1 = find(round(freq.time,2) == round(tlist(t),2));
                lmt2 = find(round(freq.time,2) == round(tlist(t)+t_win,2));
                
                lmf1 = find(round(freq.freq) == round(flist(f)));
                lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                
                data                = squeeze(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2),3));
                allsuj_nwspctrm{sb} = squeeze(mean(data,2));
                
            end
        end
    end

    load ../data/yctot/rt/rt_dis_per_delay.mat
    
    allsuj_rt{sb,1} = median([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    allsuj_rt{sb,2} = mean([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    
end

clearvars -except allsuj_*

[rho,p]     = corr([allsuj_nwspctrm{:}]',[allsuj_rt{:,2}]', 'type', 'Spearman');