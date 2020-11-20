clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   'AudViz.VirtTimeCourse.all.wav.1t90Hz.m2000p2000.mat';
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        fname_in    = ['../data/tfr/' suj '.'  lst{d} '.' ext];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo');
            freq = rmfield(freq,'hidden_trialinfo');
        end
        
        nw_chn  = [4 6]; nw_lst  = {'audR'};
        
        for l = 1:length(nw_lst)
            cfg             = []; cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes'; nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.appenddim       = 'chan';
        tmp{d}              = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq ;
        
        %         cfg                 = [];
        %         cfg.baseline        = [-1.05 0.95];
        %         cfg.baselinetype    = 'relchange';
        %         tmp{d}              = ft_freqbaseline(cfg,tmp{d});
        
    end
   
    cfg                                 = [];
    cfg.parameter                       = 'powspctrm';
    cfg.operation                       = 'subtract';
    allsuj_GA{sb,1}                     = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
    
    %     cfg                                 = [];
    %     cfg.baseline                        = [-0.2 -0.1];
    %     cfg.baselinetype                    = 'absolute';
    %     allsuj_GA{sb,1}                     = ft_freqbaseline(cfg,allsuj_GA{sb,1});
    
    cfg                                 = [];
    cfg.latency                         = [-0.1 0.5];
    cfg.frequency                       = [30 70];
    allsuj_GA{sb,1}                     = ft_selectdata(cfg,allsuj_GA{sb,1});
    
    
    allsuj_GA{sb,2}                    = allsuj_GA{sb,1};
    allsuj_GA{sb,2}.powspctrm(:,:,:)   = 0;
    
end

clearvars -except allsuj* ;

[design,neighbours] = h_create_design_neighbours(length(allsuj_GA),'eeg','t');

clear neighbours ;

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.minnbchan           = 0;cfg.tail                = 0;
cfg.clustertail         = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;
stat                    = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});

[min_p,p_val]           = h_pValSort(stat);
stat2plot               = h_plotStat(stat,0.4);

cfg                     = [];
cfg.channel             = 1;
cfg.zlim                = [-4 4];
ft_singleplotTFR(cfg,stat2plot);