clear ; clc ; dleiftrip_addpath ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    list_ext    =   {'1t90Hz.m2000p2000.mat','NewEvoked.1t90Hz.m2000p2000.mat'};
    lst_dis     =   {'DIS','fDIS'};
    
    for d = 1:2
        for e = 1:2
            fname_in    = ['../data/tfr/' suj '.'  lst_dis{d} '.AudViz.VirtTimeCourse.all.wav.' list_ext{e}];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            nw_chn  = [4 6];  nw_lst  = {'audR'};
            
            for l = 1
                cfg             = [];
                cfg.channel     = nw_chn(l,:); cfg.avgoverchan = 'yes'; nwfrq{l}        = ft_selectdata(cfg,freq);  nwfrq{l}.label  = nw_lst(l);
            end
            
            clear freq ;
            
            cfg             = [];
            cfg.parameter   = 'powspctrm';
            cfg.appenddim   = 'chan';
            tmp{e}          = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        end
        
        cfg                                     = [];
        cfg.parameter                           = 'powspctrm';
        cfg.operation                           = 'x1-x2';
        allsuj_GA{a,d}                          = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
        
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
stat2plot               = h_plotStat(stat,0.4);

for chn = 1:length(stat2plot.label)
    subplot(1,1,chn);
    cfg             = [];
    cfg.channel     = chn;
    cfg.zlim        = [-4 4];
    ft_singleplotTFR(cfg,stat2plot);
end