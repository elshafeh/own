clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.CnD.KeepTrial.wav.5t18Hz.m4000p4000.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    big_data{1}                 = ft_freqbaseline(cfg,freq);
    
    clear freq
    
    fprintf('Calculating Correlation\n');
    
    for cnd_bsl = 1:length(big_data)
        
        cfg                         = [];
        cfg.latency                 = [0 1.2];
        cfg.frequency               = [5 15];
        data_sub                    = ft_selectdata(cfg,big_data{cnd_bsl});
        
        clear freq fname suj
        
        load ../data/yctot/rt/rt_CnD_adapt.mat
        
        frq_list = data_sub.freq;
        tim_win  = 0;
        tm_list  = data_sub.time;
        ftap     = 0;
        
        for t = 1:length(tm_list)
            for f = 1:length(frq_list)
                
                x1          = find(round(data_sub.time,2) == round(tm_list(t),2)) ;
                x2          = find(round(data_sub.time,2) == round(tm_list(t)+tim_win,2)) ;
                x3          = find(round(data_sub.freq)   == round(frq_list(f)-ftap));
                x4          = find(round(data_sub.freq)   == round(frq_list(f)+ftap));

                data        = nanmean(data_sub.powspctrm(:,:,x3,x1:x2),4);
                data        = squeeze(nanmean(data,3));

                [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
                
                mask        = p < 0.05 ;
                rhoM        = rho;
                rhoF        = 0.5 .* (log((1+rhoM)./(1-rhoM)));
                
                allsuj{sb,cnd_bsl,1}.powspctrm(:,f,t)   = rhoF  ;
                allsuj{sb,cnd_bsl,2}.powspctrm(:,f,t)   = zeros(275,1) ;
                
                clear x1 x2 x3 rho*
                
            end
            
        end
        
        for cnd_rho = 1:2
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
[design,neighbours] = h_create_design_neighbours(14,'meg','t') ;

cfg                   = [];
cfg.channel           = 'MEG';
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold %
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 4;
cfg.tail              = 0;cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;cfg.neighbours        = neighbours;cfg.design            = design;
cfg.uvar              = 1;cfg.ivar              = 2;
stat{1}               = ft_freqstatistics(cfg, allsuj{:,1,1}, allsuj{:,1,2});
stat{1}.cfg           = [];

clearvars -except allsuj stat*;

tmp = stat{1} ; stat = tmp ; clear tmp ;

save('../data/yctot/stat/Correlation.p0p1200ms.7t15Hz.mat','stat');

for cnd_s = 1:length(stat)
    [min_p(cnd_s),p_val{cnd_s}]         = h_pValSort(stat{cnd_s});
end

for cnd_s = 1:length(stat)
    corr2plot{cnd_s}                    = h_plotStat(stat{cnd_s},0.05);
end

for cnd_s = 1:length(stat)
    figure;
    cfg = [];
    cfg.zlim = [-2 2];
    cfg.layout = 'CTF275.lay';
    cfg.xlim   = [1 1.1];
    ft_topoplotTFR(cfg,corr2plot{cnd_s})
end