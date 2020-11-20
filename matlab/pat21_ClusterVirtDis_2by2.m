clear ; clc ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   '.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat' ;
    lst_delay   =   '123';
    lst_dis     =   {'DIS','fDIS'};
    
    for cnd_delay = 1:length(lst_delay)
        for cnd_dis = 1:2
            
            fname_in    = ['../data/tfr/' suj '.' lst_dis{cnd_dis} lst_delay(cnd_delay)  ext1];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'hidden_trialinfo')
                freq        = rmfield(freq,'hidden_trialinfo');
            end
            
            cfg                         = [];
            cfg.channel                 = 1:2;
            tf_dis{cnd_dis}             = ft_selectdata(cfg,freq); clear freq ;
            
        end
        
        cfg                     = [];
        cfg.parameter           = 'powspctrm'; cfg.operation  = 'x1-x2';
        allsuj{sb,cnd_delay}    = ft_math(cfg,tf_dis{1},tf_dis{2}); clear tf_dis ;
    end
end

clearvars -except allsuj ;

[design,neighbours] = h_create_design_neighbours(14,'eeg','t');

neighbours = [];

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;cfg.design              = design;
cfg.neighbours          = neighbours;cfg.uvar                = 1;cfg.ivar                = 2;
cfg.minnbchan           = 0;
cfg.latency             = [-0.4 0];
cfg.frequency           = [50 100];
stat{1}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2});
stat{2}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,3});
stat{3}                 = ft_freqstatistics(cfg, allsuj{:,2}, allsuj{:,3});

for cnd_s = 1:3
    [min_p(cnd_s),p_val{cnd_s}]     = h_pValSort(stat{cnd_s});
end

for cnd_s = 1:3
    stat2plot{cnd_s}                = h_plotStat(stat{cnd_s},min_p(cnd_s)+0.00001);
end

for cnd_s = 1:3
    figure;
    for chn = 1:length(stat2plot{cnd_s}.label)
        subplot(2,1,chn)
        cfg             = [];
        cfg.channel     = chn;
        cfg.zlim        = [-4 4];
        ft_singleplotTFR(cfg,stat2plot{cnd_s});clc;
    end
end