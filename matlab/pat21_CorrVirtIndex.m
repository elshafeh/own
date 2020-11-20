clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'];
    
    load ../data/yctot/rt/rt_CnD_adapt.mat
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    cfg                         = [];
    cfg.channel                 = 1:10;
    cfg.latency                 = [0.6 1.1];
    cfg.frequency               = [7 15];
    freq                        = ft_selectdata(cfg,freq);
    
    cfg         = [];
    cfg.channel = [3 5];
    freq_L      = ft_selectdata(cfg,freq);
    cfg.channel = [4 6];
    freq_R      = ft_selectdata(cfg,freq);
    
    clear freq 
    
    freq.powspctrm  = (freq_R.powspctrm-freq_L.powspctrm) ./ ((freq_R.powspctrm+freq_L.powspctrm)/2);
    freq.time       = freq_L.time;
    freq.freq       = freq_L.freq;
    freq.label      = {'maxH','maxST'};
    
    tm_list = 0.8:0.1:0.9;
    
    for t = 1:length(tm_list)
        
        for f = 1:length(freq.freq)
            
            t1 = find(round(freq.time,2) == tm_list(t));
            t2 = find(round(freq.time,2) == tm_list(t)+0.2);
            
            data = squeeze(mean(freq.powspctrm(:,:,f,t1:t2),4));
            
            [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
            
            rhoF        = .5.*log((1+rho)./(1-rho));
            
            allsuj{sb,1}.powspctrm(:,f,t)   = rhoF  ;
            allsuj{sb,2}.powspctrm(:,f,t)   = zeros(length(freq.label),1)  ;
            
            clear x1 x2 x3 rho*
            
        end
        
    end
    
    for cnd_rho = 1:2
        
        allsuj{sb,cnd_rho}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd_rho}.freq         = freq.freq;
        allsuj{sb,cnd_rho}.time         = tm_list;
        allsuj{sb,cnd_rho}.label        = freq.label ;
        
    end
    
end

clearvars -except allsuj*; create_design_neighbours ;

neighbours = [];

for a = 1:size(allsuj,1)
    for b = 1:size(allsuj,2)
        for c = 1:size(allsuj,3)
            if size(allsuj{a,b,c}.powspctrm,1) ~= 5
                fprintf('fuck!\n');
            end
        end
    end
end

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = [];
end

cfg                   = [];
cfg.latency           = [0.8 0.9];
cfg.frequency         = [8 10];
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             %%%% First Threshold %%%%
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

[min_p,p_val]         = h_pValSort(stat);
corr2plot             = h_plotStat(stat,0.2,'no');

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

for sb = 1:14
    for cnd = 1:2
        source_avg(sb,cnd,:,:,:) = allsuj{sb,cnd}.powspctrm;
    end
end

chn = 2;

for f = 1:size(source_avg,4)
    for t = 1:size(source_avg,5)
        
        x = source_avg(:,1,chn,f,t);
        y = source_avg(:,2,chn,f,t);
        
        p(f,t) = permutation_test([x y],1000);
        
    end
end