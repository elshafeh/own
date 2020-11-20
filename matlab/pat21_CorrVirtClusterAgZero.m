% clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj     = ['yc' num2str(suj_list(sb))];
    fname   = ['../data/' suj '/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    data_sub                    = ft_freqbaseline(cfg,freq);
    
    fprintf('Calculating Correlation\n');
    
    clear freq fname suj
    
    load ../data/yctot/rt/rt_CnD_adapt.mat
    
    chn_list    = data_sub.label(1:10);
    frq_list    = 7:15 ;
    tim_win     = 0.1;
    tim_list    = 0.6:tim_win:1.1;
    
    for c = 1:length(chn_list)
        for t = 1:length(tim_list)
            for f = 1:length(frq_list)
                
                ix_f  = find(round(data_sub.freq)==round(frq_list(f)));
                ix_t1 = find(round(data_sub.time,2)==round(tim_list(t),2));
                ix_t2 = find(round(data_sub.time,2)==round(tim_list(t)+tim_win,2));
                
                data = squeeze(mean(data_sub.powspctrm(:,c,ix_f,ix_t1:ix_t2),4));
                
                [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
                rhoF        = .5.*log((1+rho)./(1-rho));
                
                
                allsuj{sb,1}.powspctrm(c,f,t)   = rhoF  ;
                allsuj{sb,2}.powspctrm(c,f,t)   = 0 ;
                
            end
        end
    end
    
    for cnd = 1:2
        
        allsuj{sb,cnd}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd}.freq         = frq_list;
        allsuj{sb,cnd}.time         = tim_list;
        allsuj{sb,cnd}.label        = chn_list ;
        
    end
    
    clear data_sub
    
    
    fprintf('Done\n');
    
    clear big_data
    
end

clearvars -except allsuj*; [design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = [];
end

cfg                   = [];
cfg.latency           = [0.8 1.1];
cfg.frequency         = [7 15];
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold %
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 0;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.design            = design;
cfg.neighbours        = neighbours;
cfg.uvar              = 1;
cfg.ivar              = 2;

stat                  = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2}); 

clearvars -except stat allsuj

[min_p,p_val]         = h_pValSort(stat);
corr2plot             = h_plotStat(stat,0.1,'no');

clearvars -except stat allsuj min_p p_val corr2plot

Summary = [];
hi      = 0 ;

for c = 1:length(corr2plot.label)
    for f = 1:length(corr2plot.freq)
        for t = 1:length(corr2plot.time)
            
            if ~isnan(corr2plot.powspctrm(c,f,t))
                if corr2plot.powspctrm(c,f,t) ~= 0
                    hi = hi + 1;
                    
                    Summary(hi).chan = corr2plot.label{c} ;
                    Summary(hi).freq = round(corr2plot.freq(f)) ;
                    Summary(hi).time = corr2plot.time(t) ;
                    
                    if corr2plot.powspctrm(c,f,t) < 0
                        Summary(hi).dire = '-ve';
                    else
                        Summary(hi).dire = '+ve';
                    end
                end
                
            end
        end
    end
end

clearvars -except stat allsuj min_p p_val Summary corr2plot