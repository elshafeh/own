clear ; clc ;

for sb = 1:14
    
    tpsm = 1;
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    for prt = 1:3
        load(['../data/pe/' suj '.pt' num2str(prt) '.CnD.Paper.TimeCourse.mat']);
        tmp{prt} = virtsens; clear virtsens;
    end
    
    data            = ft_appenddata([],tmp{:}); clear tmp ;
    
    tlist = [-0.6 0.6];
    
    for t = 1:2
        
        cfg             =   [];
        cfg.latency     =   [tlist(t) tlist(t)+0.4];
        nw_data         =   ft_selectdata(cfg,data);
        cfg.channel     =   1:2;
        cfg.avgoverchan = 'yes';
        datalo          =   ft_selectdata(cfg,nw_data);
        cfg.channel     =   3:6;
        cfg.avgoverchan = 'yes';
        datahi          =   ft_selectdata(cfg,nw_data);
        
        cfg             = [];
        cfg.method      = 'mtmfft';
        cfg.output      =  'fourier';
        cfg.keeptrials  = 'yes';
        cfg.tapsmofrq   = 2;
        cfg.keeptapers  = 'yes';
        cfg.foi         = 9;
        freqlo          = ft_freqanalysis(cfg,datalo);
        cfg.foi         = 13;
        freqhi          = ft_freqanalysis(cfg,datahi);
        
        cfg             = [];
        cfg.freqlow     = freqlo.freq;
        cfg.freqhigh    = freqhi.freq;
        cfg.method      = 'plv';
        cfg.keeptrials  = 'no';
        tmp             = ft_crossfrequencyanalysis(cfg,freqlo,freqhi);
        cross(sb,t)     = tmp.crsspctrm;
    end
    
    clearvars -except cross sb ; clc ;
    
end

[h,p_test] = ttest(cross(:,2),zeros(14,1));

% p_permute  = permutation_test([cross(:,2) zeros(14,1)],1000,'both');

load '../data/yctot/rt/rt_cond_classified.mat';

for sb = 1:14
    meanrt4index(sb)    = mean(rt_all{sb});
    medinrt4index(sb)   = median(rt_all{sb});
end

[rho_mean,p_mean]       = corr(cross(:,1),meanrt4index', 'type', 'Pearson');
[rho_median,p_median]   = corr(cross(:,1),medinrt4index', 'type', 'Pearson');