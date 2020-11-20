clear ; clc ; close all ; dleiftrip_addpath ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext1        =   'AudViz.VirtTimeCourse.all.wav' ;
    ext2        =   '1t90Hz.m2000p2000.mat';
    lst         =   'LRN';
    
    for cnd_cue = 1:length(lst)
        
        fname_in    = ['../data/tfr/' suj '.'  lst(cnd_cue) 'nDT.' ext1 '.' ext2];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo')
            freq        = rmfield(freq,'hidden_trialinfo');
        end
        
        nw_chn      = [3 5;4 6];nw_lst      = {'audL','audR'};
        
        for l = 1:2
            cfg             = [];cfg.channel     = nw_chn(l,:);cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg                     = [];cfg.parameter           = 'powspctrm';cfg.appenddim           = 'chan';
        allsuj{a,cnd_cue}          = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        cfg                     = [];
        cfg.baseline            = [-0.2 -0.1];
        cfg.baselinetype        = 'relchange';
        allsuj{a,cnd_cue}       = ft_freqbaseline(cfg,allsuj{a,cnd_cue} );
        
    end
end

clearvars -except allsuj;

[design,neighbours] = h_create_design_neighbours(14,'eeg','t');

neighbours = [];

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
cfg.minnbchan           = 0;
cfg.latency             = [0 0.6];
cfg.frequency           = [50 90];

stat{1}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2});
stat{2}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,3});
stat{3}                 = ft_freqstatistics(cfg, allsuj{:,2}, allsuj{:,3});

for cnd_s = 1:3
    [min_p(cnd_s),p_val{cnd_s}]           = h_pValSort(stat{cnd_s});
    stat2plot{cnd_s}       = h_plotStat(stat{cnd_s},0.3);
end

i = 0 ;

for chn = 1:2
    for cnd_s = 1:3
        i =i +1;
        subplot(2,3,i)
        cfg                    = [];
        cfg.channel            = chn;
        cfg.zlim               = [-4 4];
        ft_singleplotTFR(cfg,stat2plot{cnd_s});
    end
end