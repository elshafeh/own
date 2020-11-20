clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    if strcmp(suj,'yc1')
        fname = ['../data/' suj '/tfr/' suj '.CnD.KeepTrial.wav.5t18Hz.m3p3.mat'];
    else
        fname = ['../data/' suj '/tfr/' suj '.CnD.KeepTrial.wav.5t18Hz.m4p4.mat'];
    end
    
    %     fname = ['../data/' suj '/tfr/' suj '.CnD.KTPlanar.wav.5t18Hz.m3p3.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    data_sub                    = freq;
    
    clear freq
    
    fprintf('Calculating Correlation\n');
    
    clear freq fname suj
    
    load ../data/yctot/rt/rt_CnD_adapt.mat
    
    frq_list = 7:15;
    tim_win  = 0.1;
    tm_list  = 0.6:0.1:0.9;
    
    for t = 1:length(tm_list)
        
        for f = 1:length(frq_list)
            
            x1 = find(round(data_sub.time,2) == round(tm_list(t),2)) ;
            x2 = find(round(data_sub.time,2) == round(tm_list(t)+tim_win,2)) ;
            x3 = find(round(data_sub.freq)   == round(frq_list(f)));
            
            data = nanmean(data_sub.powspctrm(:,:,x3,x1:x2),4);
            
            [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
            
            rho_mask    = p < 0.05 ;
            
            rhoM        = rho .* rho_mask ;
            
            rhoF        = .5.*log((1+rho)./(1-rho));
            rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
            
            
            allsuj{sb,1}.powspctrm(:,f,t)   = rhoF  ;
            allsuj{sb,2}.powspctrm(:,f,t)   = rhoMF ;
            allsuj{sb,3}.powspctrm(:,f,t)   = zeros(275,1) ;
            
            clear x1 x2 x3 rho*
            
        end
        
    end
    
    for cnd_rho = 1:3
        
        allsuj{sb,cnd_rho}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd_rho}.freq         = frq_list;
        allsuj{sb,cnd_rho}.time         = tm_list;
        allsuj{sb,cnd_rho}.label        = data_sub.label ;
        
    end
    
    clear data_sub
    
    
    fprintf('Done\n');
    
    clear big_data
    
end

clearvars -except allsuj*; create_design_neighbours ;

cfg                   = [];
cfg.channel           = 'MEG';
cfg.latency           = [0.6 1.1];
cfg.frequency         = [7 15];
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold %
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

stat{1}               = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,3}); % non corrected versus Zero unmasked

for cnd_s = 1
    
    [min_p(cnd_s),p_val{cnd_s}]         = h_pValSort(stat{cnd_s});
    corr2plot{cnd_s}                    = h_plotStat(stat{cnd_s},0.1,'no');
    
end

cnd_title = {'bCorrV0unM','bCorrV0M','nCorrV0unM','nCorrV0M'};

for cnd_s = 1
    
    cfg                             = [];
    cfg.frequency                   = [7 15];
    cfg.avgoverfreq                 = 'yes';
    corr2plotavgoverfreq{cnd_s}     = ft_selectdata(cfg,corr2plot{cnd_s} );
end

for cnd_s = 1
    cfg                             = [];
    cfg.latency                     = [0.7 0.9];
    cfg.avgovertime                 = 'yes';
    corr2plotavgovertime{cnd_s}     = ft_selectdata(cfg,corr2plot{cnd_s} );
    
end

for cnd_s = 1
    
    figure;
    
    for a = 1:length(allsuj{1,1}.freq)
        
        subplot(3,3,a)
        
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.ylim        = [stat{1,1}.freq(a) stat{1,1}.freq(a)];
        cfg.zlim        = [-2 2];
        cfg.comment     = 'no';
        ft_topoplotTFR(cfg,corr2plotavgovertime{cnd_s});
        
        title([cnd_title{cnd_s} ' ' num2str(stat{1,1}.freq(a)) 'Hz']);
        
    end
    
    %     saveFigure(gcf,['../plots/Corr/Sensor/per_freq/' cnd_title{cnd_s} '.png']);
    %     close all;
    
end

for cnd_s = 1
    
    figure;
    
    for a = 1:length(stat{1,1}.time)
        
        subplot(3,4,a)
        
        cfg             = [];
        cfg.layout      = 'CTF275.lay';
        cfg.xlim        = [stat{1,1}.time(a) stat{1,1}.time(a)];
        cfg.zlim        = [-2 2];
        cfg.comment     = 'no';
        ft_topoplotTFR(cfg,corr2plotavgoverfreq{cnd_s});
        
        title([num2str(round(stat{1,1}.time(a)*1000)) 'ms']);
        
    end
    
    %     saveFigure(gcf,['../plots/Corr/Sensor/per_time/' cnd_title{cnd_s} '.png']);
    %     close all;
    
end