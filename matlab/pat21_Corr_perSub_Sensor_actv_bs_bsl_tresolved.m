clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    if strcmp(suj,'yc1')
        fname = ['../data/' suj '/tfr/' suj '.CnD.KeepTrial.wav.5t18Hz.m3p3.mat'];
    else
        fname = ['../data/' suj '/tfr/' suj '.CnD.KeepTrial.wav.5t18Hz.m4p4.mat'];
    end
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    data_sub = freq ;
    
    clear freq fname suj
    
    load ../data/yctot/rt/rt_CnD_adapt.mat
    
    fprintf('Calculating Correlation\n');
    
    tact1 = find(round(data_sub.time,2) == 0.2) ;
    tact2 = find(round(data_sub.time,2) == 1.2) ;
    
    t_window    = tact1:tact2;
    t_width     = length(tact1:tact2);
    
    
    % calculate baseline
    
    tbsl1 = find(round(data_sub.time,2) == -0.60) ;
    tbsl2 = find(round(data_sub.time,2) == -0.20) ;
    
    for f = 1:length(data_sub.freq)
        
        data = nanmean(data_sub.powspctrm(:,:,f,tbsl1:tbsl2),4);
        
        [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
        rho_mask    = p < 0.05 ;
        rhoM        = rho .* rho_mask ;
        rhoF        = .5.*log((1+rho)./(1-rho));
        rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
        
        allsuj{sb,2}.powspctrm(:,f,1:t_width)  = repmat(rhoF,1,1,t_width) ;
        allsuj{sb,4}.powspctrm(:,f,1:t_width)  = repmat(rhoMF,1,1,t_width) ;
        
    end
    
    for t = 1:t_width
        
        for f = 1:length(data_sub.freq)
            
            data = squeeze(data_sub.powspctrm(:,:,f,t_window(t)));
            
            [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
            rho_mask    = p < 0.05 ;
            rhoM        = rho .* rho_mask ;
            rhoF        = .5.*log((1+rho)./(1-rho));
            rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
            
            
            allsuj{sb,1}.powspctrm(:,f,t)                  = rhoF;
            allsuj{sb,3}.powspctrm(:,f,t)                  = rhoMF;
            
            clear x1 x2 x3 data rho*
            
        end
        
    end
    
    for cnd = 1:4
        
        allsuj{sb,cnd}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd}.freq         = data_sub.freq;
        allsuj{sb,cnd}.time         = 0.2:0.05:1.2;
        allsuj{sb,cnd}.label        = data_sub.label ;
        
    end
    
    fprintf('Done\n');
    
    clear tmp data
    
end

clearvars -except allsuj*; create_design_neighbours ;

cfg                   = [];
cfg.channel           = 'MEG';
cfg.latency           = [0.2 1.1];
cfg.frequency         = [5 15];
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             %%%% First Threshold %%%%
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 4;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.design            = design;
cfg.uvar              = 1;
cfg.ivar              = 2;

stat{1}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2});
stat{2}                 = ft_freqstatistics(cfg, allsuj{:,3}, allsuj{:,4});

for cnd_s = 1:2
    
    [min_p(cnd_s),p_val{cnd_s}]         = h_pValSort(stat{cnd_s});
    corr2plot{cnd_s}                    = h_plotStat(stat{cnd_s},0.05,'yes');
    
end

cnd_title = {'vsBsluM','vsBslM'};

for cnd_s = 1:2
    
    cfg                             = [];
    cfg.frequency                   = [7 15];
    cfg.avgoverfreq                 = 'yes';
    corr2plotavgoverfreq{cnd_s}     = ft_selectdata(cfg,corr2plot{cnd_s} );
    
    cfg                             = [];
    cfg.latency                     = [0.4 1];
    cfg.avgovertime                 = 'yes';
    corr2plotavgovertime{cnd_s}     = ft_selectdata(cfg,corr2plot{cnd_s} );
    
end

for cnd_s = 1:2
    
    figure;
    
    for a = 1:length(allsuj{1,1}.freq)
        
        subplot(3,3,a)
        
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.ylim        = [allsuj{1,1}.freq(a) allsuj{1,1}.freq(a)];
        cfg.zlim        = [-2 2];
        cfg.comment     = 'no';
        ft_topoplotTFR(cfg,corr2plotavgovertime{cnd_s});
        
        title([cnd_title{cnd_s} ' ' num2str(allsuj{1,1}.freq(a)) 'Hz']);
        
    end
    
    saveFigure(gcf,['../plots/Corr/Sensor/per_freq/' cnd_title{cnd_s} '.png']);
    close all;
    
end

for cnd_s = 1:2
    
    figure;
    
    for a = 1:length(allsuj{1,1}.time)
        
        subplot(3,3,a)
        
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.xlim        = [allsuj{1,1}.time(a) allsuj{1,1}.time(a)];
        cfg.zlim        = [-2 2];
        cfg.comment     = 'no';
        ft_topoplotTFR(cfg,corr2plotavgoverfreq{cnd_s});
        
        title([cnd_title{cnd_s} ' ' num2str(round(allsuj{1,1}.time(a)*1000)) 'ms']);
        
    end
    
    saveFigure(gcf,['../plots/Corr/Sensor/per_time/' cnd_title{cnd_s} '.png']);
    close all;
    
end