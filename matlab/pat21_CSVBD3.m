clear ; clc ; dleiftrip_addpath ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext         =   'AudViz.VirtTimeCourse.all.wav.1t90Hz.m2000p2000.mat';
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        fname_in    = ['../data/tfr/' suj '.'  lst{d} '.' ext];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo');
            freq = rmfield(freq,'hidden_trialinfo');
        end
        
        nw_chn  = [3 5;4 6];
        nw_lst  = {'audL','audR'};
        
        for l = 1:length(nw_lst)
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        clear freq
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';
        cfg.appenddim   = 'chan';
        tmp{d}          = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        clear freq;
    end
    
    cfg                                     = [];
    cfg.parameter                           = 'powspctrm';
    cfg.operation                           = 'subtract';
    freq                                    = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
    
    cfg                                     = [];
    cfg.latency                             = [-0.1 0.5];
    allsuj_activation{a,1}                  = ft_selectdata(cfg, freq);
    
    cfg                                     = [];
    cfg.latency                             = [-0.2 -0.1];
    cfg.avgovertime                         = 'yes';
    allsuj_baselineAvg{a,1}                 = ft_selectdata(cfg, freq);
    
    allsuj_baselineRep{a,1}                 = allsuj_activation{a,1};
    allsuj_baselineRep{a,1}.powspctrm       = repmat(allsuj_baselineAvg{a,1}.powspctrm,1,1,size(allsuj_activation{a,1}.powspctrm,3));
   
    clear allsuj_baselineAvg ;
    
end

clearvars -except allsuj_*

[design,neighbours] = h_create_design_neighbours(14,'eeg','t');
clear neighbours ;

for n = 1:length(allsuj_activation{1,1}.label)
    neighbours(n).label = allsuj_activation{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.minnbchan           = 0;cfg.tail                = 0;
cfg.clustertail         = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;
cfg.frequency           = [35 65] ;
stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});
stat                    = rmfield(stat,'cfg');
[min_p,p_val]           = h_pValSort(stat);
stat2plot               = h_plotStat(stat,0.2);

for c = 1:2
    subplot(2,1,c)
    cfg             = [];
    cfg.channel     = c;
    cfg.zlim        = [-4 4];
    ft_singleplotTFR(cfg,stat2plot);
end