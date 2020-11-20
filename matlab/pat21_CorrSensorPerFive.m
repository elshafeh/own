clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.CnD.KeepTrial.wav.5t18Hz.m4000p4000.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    load ../data/yctot/rt/sexyfive.mat
    load ../data/yctot/rt/rt_CnD_adapt.mat

    for cp = 1:5
        nwspctrm(cp,:,:,:) = squeeze(mean(freq.powspctrm(sexyfive{sb,cp},:,:,:),1));
        rt2corr(cp,1)      = median(rt_all{sb}(sexyfive{sb,cp}));
    end
    
    freq.powspctrm  = nwspctrm ; clear nwspctrm 
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    big_data{1}                 = ft_freqbaseline(cfg,freq);
    cfg.baselinetype            = 'absolute';
    big_data{2}                 = ft_freqbaseline(cfg,freq);
    big_data{3}                 = freq;
    
    clear freq
    
    fprintf('Calculating Correlation\n');
    
    for cnd_bsl = 1:length(big_data)
        
        data_sub = big_data{cnd_bsl} ; 
        
        clear freq fname suj
        
        frq_list = 7:15; tim_win  = 0.1;tm_list  = 0.6:tim_win:1;
        
        for t = 1:length(tm_list)
            for f = 1:length(frq_list)
                
                x1          = find(round(data_sub.time,2) == round(tm_list(t),2)) ;
                x2          = find(round(data_sub.time,2) == round(tm_list(t)+tim_win,2)) ;
                x3          = find(round(data_sub.freq)   == round(frq_list(f)));
                
                data        = nanmean(data_sub.powspctrm(:,:,x3,x1:x2),4);
                
                [rho,p]     = corr(data,rt2corr, 'type', 'Spearman');
                mask        = p < 0.05 ;
                rhoM        = rho .* mask ;
                
                rhoF        = (1+rhoM)./(1-rhoM);
                rhoF        = log(rhoF);
                rhoF        = 0.5 .* rhoF;
                
                allsuj{sb,cnd_bsl,1}.powspctrm(:,f,t)   = rhoF  ;
                allsuj{sb,cnd_bsl,2}.powspctrm(:,f,t)   = zeros(275,1) ;
                allsuj{sb,cnd_bsl,3}.powspctrm(:,f,t)   = rhoM  ;
                allsuj{sb,cnd_bsl,4}.powspctrm(:,f,t)   = rho  ;

                clear x1 x2 x3 rho*
                
            end
        end
        
        for cnd_rho = 1:4
            allsuj{sb,cnd_bsl,cnd_rho}.dimord       = 'chan_freq_time';
            allsuj{sb,cnd_bsl,cnd_rho}.freq         = frq_list;
            allsuj{sb,cnd_bsl,cnd_rho}.time         = tm_list;
            allsuj{sb,cnd_bsl,cnd_rho}.label        = data_sub.label ;
        end
        
        clear data_sub
        
    end
    
    fprintf('Done\n');
    
    clear big_data
    
end

clearvars -except allsuj*; 
[design,neighbours] = h_create_design_neighbours(size(allsuj,1),'meg','t') ;

cfg                   = [];
cfg.channel           = 'MEG';
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold %
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 2;
cfg.tail              = 0;cfg.clustertail       = 0;cfg.alpha             = 0.025;cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;cfg.design            = design;
cfg.uvar              = 1;cfg.ivar              = 2;

for ix_com = [1 3 4];
    for cnd_s = 1:3
        stat{cnd_s,ix_com}                                  = ft_freqstatistics(cfg, allsuj{:,cnd_s,ix_com}, allsuj{:,cnd_s,2});
        [min_p(cnd_s,ix_com),p_val{cnd_s,ix_com}]           = h_pValSort(stat{cnd_s,ix_com});
    end
end

for cnd_s = 1:3
    corr2plot{cnd_s}                    = h_plotStat(stat{cnd_s},0.05);
end

for cnd_s = 1:3
    figure;
    cfg = [];
    cfg.xlim = 0.6:0.1:1;
    cfg.zlim = [-2 2];
    cfg.layout = 'CTF275.lay';
    ft_topoplotTFR(cfg,corr2plot{cnd_s})
end

for cnd_s = 1:3
    figure;
    for a = 1:length(stat{cnd_s}.freq)
        subplot(3,3,a)
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.ylim        = [stat{cnd_s}.freq(a) stat{cnd_s}.freq(a)];
        cfg.zlim        = [-2 2];
        cfg.comment     = 'no';
        ft_topoplotTFR(cfg,corr2plot{cnd_s});
        title([num2str(stat{cnd_s}.freq(a)) 'Hz']);
        
    end
end

gavg            = ft_freqgrandaverage([],allsuj{:,3,1});
cfg             = [];
cfg.latency     = [0.6 1];
cfg.frequency   = [8 11];
cfg.avgovertime = 'yes';
cfg.avgoverfreq = 'yes';
gavg            = ft_selectdata(cfg,gavg);
mask            = ft_selectdata(cfg,corr2plot{3});
mask.powspctrm(isnan(mask.powspctrm)) = 0;
mask            = mask.powspctrm ~= 0;
gavg.powspctrm  = gavg.powspctrm .* mask;

cfg             = [];
cfg.layout      = 'CTF275.lay';
cfg.zlim        = [-1 1];
ft_topoplotTFR(cfg,gavg);