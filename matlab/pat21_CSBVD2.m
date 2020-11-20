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
        
        nw_chn  = [4 6];
        nw_lst  = {'audR'};
        
        for l = 1
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.appenddim       = 'chan';
        tmp                 = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        clear freq;
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        allsuj_GA{a,d}      = ft_freqbaseline(cfg,tmp); 
        
    end
end

clearvars -except allsuj_*

[design,neighbours] = h_create_design_neighbours(length(allsuj_GA),'eeg','t');
clear neighbours ;

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};
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
cfg.frequency           = [7 90] ;
cfg.latency             = [-0.2 0.6] ;
stat                    = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
stat                    = rmfield(stat,'cfg');
[min_p,p_val]           = h_pValSort(stat);
stat2plot               = h_plotStat(stat,0.9);

for chn = 1:length(stat2plot.label)
    subplot(1,2,chn)
    cfg             = [];
    cfg.channel     = chn;
    cfg.zlim        = [-5 5];
    ft_singleplotTFR(cfg,stat2plot);
    vline(0,'-k');
end