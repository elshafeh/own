clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   'AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat';
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        fname_in    = ['../data/tfr/' suj '.'  lst{d} '.' ext];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo')
            freq        = rmfield(freq,'hidden_trialinfo');
        end
        
        cfg             = [];
        cfg.channel     = 2;
        tmp{d}          = ft_selectdata(cfg,freq);
        
    end
    
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.operation       = 'subtract';
    freq                = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
    
    allsuj_GA{sb,1}      = freq;
    
    clear freq ; 

    load ../data/yctot/rt/rt_dis_per_delay.mat
    
    allsuj_rt{sb,1} = median([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    allsuj_rt{sb,2} = mean([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    
end

clearvars -except allsuj* ;

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};
    neighbours(n).neighblabel = [];
end

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT'; 
cfg.clusterstatistics   = 'maxsum'; 
cfg.correctm            = 'cluster';cfg.clusteralpha        = 0.05;    
cfg.minnbchan           = 0;cfg.tail                = 0;
cfg.clustertail         = 0;cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;cfg.neighbours          = neighbours;
cfg.ivar                = 1;           
cfg.frequency           = [50 100];
cfg.latency             = [0.4 0.5];

lst_tst = {'Pearson','Spearman'};

for x = 2
    for y = 1:2
        cfg.design (1,1:14)     = [allsuj_rt{:,y}];
        cfg.type                = lst_tst{x};
        stat{x,y}               = ft_freqstatistics(cfg, allsuj_GA{:});
        [min_p(x,y),p_val{x,y}] = h_pValSort(stat{x,y});
    end
end

for x = 2
    for y = 1:2
        stat2plot{x,y}               = h_plotStat(stat{x,y},0.2);
    end
end

for x = 2
    for y = 1:2
        figure;
        cfg = [];
        cfg.zlim = [-4 4];
        ft_singleplotTFR(cfg,stat2plot{x,y});
    end
end

gavg = ft_freqgrandaverage([],allsuj_GA{:});

f0      = stat{2,1}.freq(1);f1      = stat{2,1}.freq(end);
t0      = stat{2,1}.time(1);t1      = stat{2,1}.time(end);

zlim ='maxabs';
tf_masked(gavg,stat{2,1},f0, f1,t0,t1,'audR',0.6,0.1,zlim);
vline(0,'--k');
vline(0.3,'--k');
xlim([0 0.5]);
set(gca,'fontsize',18)
title('');
set(gca,'FontWeight','bold')
title('');