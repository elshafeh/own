clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.CnD.KeepTrial.wav.5t18Hz.m4000p4000.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    %     cfg                         = [];
    %     cfg.baseline                = [-0.6 -0.2];
    %     cfg.baselinetype            = 'relchange';
    %     data_sub                    = ft_freqbaseline(cfg,freq);
    
    data_sub = freq ;
    
    clear freq fname suj
    
    load '../data/yctot/rt/rt_cond_classified.mat';
    
    for cond_cue = 1:3 % 1) N 2) L 3) R
        
        frq_list = 7:15;
        tim_win  = 0.1 ;
        tm_list  = 0:tim_win:1.1;
        
        for t = 1:length(tm_list)
            
            for f = 1:length(frq_list)
                
                x1          = find(round(data_sub.time,2) == round(tm_list(t),2)) ;
                x2          = find(round(data_sub.time,2) == round(tm_list(t)+tim_win,2)) ;
                x3          = find(round(data_sub.freq)   == round(frq_list(f)));
                
                data        = nanmean(data_sub.powspctrm(rt_indx{sb,cond_cue},:,x3,x1:x2),4);
                
                [rho,p]     = corr(data,rt_classified{sb,cond_cue} , 'type', 'Spearman');
                rhoF        = .5.*log((1+rho)./(1-rho));
                
                topowspctrum(:,f,t)   = rhoF;
                
                clear data
                
            end
            
        end
        
        allsuj{sb,cond_cue}.powspctrm   =  topowspctrum   ; clear topowspctrum
        allsuj{sb,cond_cue}.label       =  data_sub.label ;
        allsuj{sb,cond_cue}.freq        =  frq_list;
        allsuj{sb,cond_cue}.time        =  tm_list;
        allsuj{sb,cond_cue}.dimord      = 'chan_freq_time';
        
    end
    
    clear data_sub
    
    allsuj{sb,4}                    = allsuj{sb,3};
    allsuj{sb,4}.powspctrm(:,:,:)   = 0 ;
    
end

clearvars -except allsuj ; [design,neighbours] = h_create_design_neighbours(14,'meg','t');

cfg                     = [];
cfg.channel             = 'MEG';cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic    = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha                = 0.025;
cfg.tail                = 0;cfg.clustertail             = 0;
cfg.design              = design;cfg.neighbours         = neighbours;
cfg.uvar                = 1;cfg.ivar                    = 2;
cfg.minnbchan           = 2;cfg.numrandomization        = 1000;

% cfg.latency             = [0.6 1];
% cfg.avgovertime         = 'yes';

stat{1}                 = ft_freqstatistics(cfg, allsuj{:,3},allsuj{:,1}); % R v U
stat{2}                 = ft_freqstatistics(cfg, allsuj{:,2},allsuj{:,1}); % L v U
stat{3}                 = ft_freqstatistics(cfg, allsuj{:,3},allsuj{:,2}); % R v L
stat{4}                 = ft_freqstatistics(cfg, allsuj{:,3},allsuj{:,4}); % R v 0
stat{5}                 = ft_freqstatistics(cfg, allsuj{:,2},allsuj{:,4}); % L v 0
stat{6}                 = ft_freqstatistics(cfg, allsuj{:,1},allsuj{:,4}); % R v 0

for cnd_s = 1:length(stat)
    [min_p(cnd_s), p_val{cnd_s}]          = h_pValSort(stat{cnd_s}) ;
end

for cnd_s = 1:length(stat)
    stat2plot{cnd_s}               = h_plotStat(stat{cnd_s},0.000000000000001,min_p(cnd_s)+0.00001);
end

for cnd_s = 1:length(stat)
    subplot(3,2,cnd_s);
    cfg                     =   [];
    cfg.zlim                =   [-1 1];
    cfg.comment             = 'no';
    cfg.marker              = 'off';
    cfg.layout              = 'CTF275.lay';
    ft_topoplotTFR(cfg,stat2plot{cnd_s});
end