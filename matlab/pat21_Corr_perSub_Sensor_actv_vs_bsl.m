clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];

    fname = ['../data/' suj '/tfr/' suj '.CnD.KeepTrial.wav.5t18Hz.m4p4.mat'];

    fprintf('Loading %30s\n',fname);
    load(fname);
    
    data_sub = freq ; 
    
    clear freq fname suj
    
    load ../data/yctot/rt/rt_CnD_adapt.mat
    
    frq_list = 8:15 ;
    tim_win  = 0.2  ;
    tm_list  = [-0.6 0.6:tim_win:1.2];
    
    fprintf('Calculating Correlation\n');
    
    for t = 1:length(tm_list)
        
        for f = 1:length(frq_list)
            
            x1 = find(round(data_sub.time,2) == round(tm_list(t),2)) ; 
            
            if t == 1
                x2 = find(round(data_sub.time,2) == round(tm_list(t)+0.4,2)) ;
            else
                x2 = find(round(data_sub.time,2) == round(tm_list(t)+tim_win,2)) ;
            end
            
            x3 = find(round(data_sub.freq) == round(frq_list(f)));
            
            data = nanmean(data_sub.powspctrm(:,:,x3,x1:x2),4);
            
            [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
            
            rho_mask    = p < 0.05 ;
            
            rhoM        = rho .* rho_mask ;
            
            rhoF        = .5.*log((1+rho)./(1-rho));
            rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
            
            if t == 1
                allsuj{sb,2}.powspctrm(:,f,t:length(tm_list)-1)  = repmat(rhoF,1,1,length(t:length(tm_list)-1)) ;
                allsuj{sb,4}.powspctrm(:,f,t:length(tm_list)-1)  = repmat(rhoMF,1,1,length(t:length(tm_list)-1)) ;
            else
                allsuj{sb,1}.powspctrm(:,f,t-1)                  = rhoF;
                allsuj{sb,3}.powspctrm(:,f,t-1)                  = rhoMF;
            end
            
            clear x1 x2 x3 data rho*
            
        end
        
    end
    
    for cnd = 1:4
        
        allsuj{sb,cnd}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd}.freq         = frq_list;
        allsuj{sb,cnd}.time         = tm_list(2:end);
        allsuj{sb,cnd}.label        = data_sub.label ;
        
    end
    
    fprintf('Done\n');
    
    clear tmp data
    
end

clearvars -except allsuj* frq_list tm_list; create_design_neighbours ;

cfg                   = [];
cfg.channel           = 'MEG';
cfg.latency           = [tm_list(1)     tm_list(end)];
cfg.frequency         = [frq_list(1)    frq_list(end)];
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             %%%% First Threshold %%%%
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 2;
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

for cnd_s = 1%:2
    
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

for cnd_s = 1%:2
    
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
    
    %     saveFigure(gcf,['../plots/Corr/Sensor/per_time/' cnd_title{cnd_s} '.png']);
    %     close all;
    
end