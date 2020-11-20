clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.nDT.AudFrontal.VirtTimeCourse.KeepTrial.wav.50t100Hz.m2000p1000.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    freq                = rmfield(freq,'hidden_trialinfo');
    
    nw_chn  = [1 1];
    nw_lst  = {'audR'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:); cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq); nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = [];
    cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan'; freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                         = [];
    cfg.baseline                = [-1.4 -1.3]; cfg.baselinetype            = 'relchange';
    data_sub                    = ft_freqbaseline(cfg,freq); clear freq;
    
    load ../data/yctot/rt/rt_cond_classified.mat
    
    cfg                         = [];
    cfg.frequency               = [50 100];
    cfg.latency                 = [0 0.3];
    data_sub                    = ft_selectdata(cfg,data_sub);
    
    for t = 1:length(data_sub.time)
        for f = 1:length(data_sub.freq)
            
            %                 lmt1                            = find(round(data_sub.time,2) == round(tlist(t),2));
            %                 lmt2                            = find(round(data_sub.time,2) == round(tlist(t)+t_win,2));
            %                 lmf1                            = find(round(data_sub.freq) == round(flist(f)));
            %                 lmf2                            = find(round(data_sub.freq) == round(flist(f)+ftap));
            
            data                            = squeeze(data_sub.powspctrm(:,:,f,t));
            [rho,p]                         = corr(data,rt_all{sb} , 'type', 'Spearman');
            
            rhoM                            = rho;
            rhoF                            = .5.*log((1+rhoM)./(1-rhoM));
            
            allsuj{sb,1}.powspctrm(:,f,t)   = rhoF  ;
            allsuj{sb,2}.powspctrm(:,f,t)   = zeros(length(data_sub.label),1) ;
            
            clear x1 x2 x3 rho*
            
        end
    end
    
    for cnd_rho = 1:2
        allsuj{sb,cnd_rho}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd_rho}.freq         = data_sub.freq;
        allsuj{sb,cnd_rho}.label        = data_sub.label ;
        allsuj{sb,cnd_rho}.time         = data_sub.time;
    end
    
    clear data_sub
    
    fprintf('Done\n');
    
end

clearvars -except allsuj*;

[design,neighbours] = h_create_design_neighbours(14,'eeg','t');

neighbours = [];

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label         = allsuj{1,1}.label{n};
    neighbours(n).neighblabel   = [];
end

cfg                   = [];
cfg.method            = 'montecarlo';
cfg.statistic         = 'depsamplesT';
cfg.correctm          = 'cluster';cfg.clusteralpha      = 0.05;
cfg.clusterstatistic  = 'maxsum';cfg.minnbchan         = 0;cfg.tail              = 0;cfg.clustertail       = 0;
cfg.alpha             = 0.025;cfg.numrandomization  = 1000;cfg.design            = design;cfg.neighbours        = neighbours;
cfg.uvar              = 1;cfg.ivar              = 2;cfg.frequency         = [50 70];
stat                  = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2});
[min_p,p_val]         = h_pValSort(stat);
corr2plot             = h_plotStat(stat,0.3);

for chn = 1
    subplot(1,1,chn)
    cfg             = [];
    cfg.zlim        = [-4 4];
    cfg.channel     = chn;
    ft_singleplotTFR(cfg,corr2plot) ; clc;
end