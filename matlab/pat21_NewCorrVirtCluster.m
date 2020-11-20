clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.CnD.MaxAudVis.VirtTimeCourse.Keeptrial.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    freq                = rmfield(freq,'hidden_trialinfo');
    
    nw_chn  = [1 2; 3 5; 4 6];  nw_lst  = {'occ','audL','audR'};
    
    for l = 1:3
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = [];
    cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
    freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    load ../data/yctot/rt/rt_cond_classified.mat
    
    cfg                 = [];
    cfg.frequency       = [7 15];
    data_sub            = ft_selectdata(cfg,freq);
    
    clear freq fname suj big_data
    
    t_win  = 0.1;
    t_list = 0.6:t_win:1;
    
    for cnd_cue = 1:3
        for t = 1:length(t_list)
            for f = 1:length(data_sub.freq)
                
                lmt1 = find(round(data_sub.time,2) == round(t_list(t),2));
                lmt2 = find(round(data_sub.time,2) == round(t_list(t)+t_win,2));
                
                data = squeeze(mean(data_sub.powspctrm(rt_indx{sb,cnd_cue},:,f,lmt1:lmt2),4));
                [rho,p]     = corr(data,rt_classified{sb,cnd_cue} , 'type', 'Spearman');
                rhoF        = .5.*log((1+rho)./(1-rho));
                
                allsuj{sb,cnd_cue,1}.powspctrm(:,f,t)   = rhoF  ;
                allsuj{sb,cnd_cue,2}.powspctrm(:,f,t)   = zeros(length(data_sub.label),1) ;
                
                clear x1 x2 x3 rho*
                
            end
        end
        
        for cnd_rho = 1:2
            allsuj{sb,cnd_cue,cnd_rho}.dimord       = 'chan_freq_time';
            allsuj{sb,cnd_cue,cnd_rho}.freq         = data_sub.freq;
            allsuj{sb,cnd_cue,cnd_rho}.label        = data_sub.label ;
            allsuj{sb,cnd_cue,cnd_rho}.time         = t_list;
        end
        
    end
end

clearvars -except allsuj*;

[design,neighbours] = h_create_design_neighbours(14,'eeg','t');

neighbours = [];

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label         = allsuj{1,1}.label{n};
    neighbours(n).neighblabel   = [];
end

cfg                   = [];
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'depsamplesT';    % T test
cfg.correctm          = 'bonferroni';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 0;cfg.tail              = 0;cfg.clustertail       = 0;
cfg.alpha             = 0.025;cfg.numrandomization  = 1000;
cfg.design            = design;cfg.neighbours        = neighbours;
cfg.uvar              = 1;cfg.ivar              = 2;

for cnd_cue = 1:3
    stat{cnd_cue}                                   = ft_freqstatistics(cfg, allsuj{:,cnd_cue,1}, allsuj{:,cnd_cue,2});
    [min_p(cnd_cue),p_val{cnd_cue}]              = h_pValSort(stat{cnd_cue});
end

for cnd_cue = 1:3
    
    corr2plot{cnd_cue}               = h_plotStat(stat{cnd_cue},0.1);
    figure;
    for chn= 1:length(corr2plot{cnd_cue}.label)
        subplot(3,1,chn);
        cfg             = [];
        cfg.channel     = chn;
        cfg.zlim        = [-4 4];
        cfg.colorbar    = 'no';
        ft_singleplotTFR(cfg,corr2plot{cnd_cue} ) ; clc;
    end
end