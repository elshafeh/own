clear ; clc ;  dleiftrip_addpath ;

load ../data/yctot/gavg/LRNnDT.pe.mat

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.nDT.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    if isfield(freq,'hidden_trialinfo')
        freq    = rmfield(freq,'hidden_trialinfo');
    end
    
    nw_chn  = [1 1];  nw_lst  = {'audR'};
    %     nw_chn  = [1 1; 2 2; 3 5; 4 6];  nw_lst  = {'occL','occR','audL','audR'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg                         = [];
    cfg.parameter               = 'powspctrm';cfg.appenddim   = 'chan';
    freq                        = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                         = [];
    cfg.baseline                = [-1.4 -1.3];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    t_win   = 0.05;
    tlist   = 0:t_win:0.4-t_win;
    ftap    = 10;
    flist   = 50:ftap:90;
    nchn    = 1;
    
    nwspctrm = [];
    
    for chn = 1:length(nchn)
        for t = 1:length(tlist)
            for f = 1:length(flist)
                
                lmt1 = find(round(freq.time,2) == round(tlist(t),2));
                lmt2 = find(round(freq.time,2) == round(tlist(t)+t_win,2));
                
                lmf1 = find(round(freq.freq) == round(flist(f)));
                lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                
                data                = squeeze(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2),3));
                nwspctrm(chn,f,t)   = squeeze(mean(data,2));
                
            end
        end
    end
    
    allsuj_GA{sb,1}.powspctrm = nwspctrm;
    allsuj_GA{sb,1}.time      = tlist;
    allsuj_GA{sb,1}.freq      = flist;
    allsuj_GA{sb,1}.dimord    = freq.dimord;
    allsuj_GA{sb,1}.label     = freq.label(nchn);clear nwspctrm freq;
    
    
    avg = ft_timelockgrandaverage([],allsuj{sb,:});
    cfg = []; cfg.baseline = [-0.1 0]; avg = ft_timelockbaseline(cfg,avg);
    
    cfg                 = [];
    cfg.method          = 'amplitude';
    gfp                 = ft_globalmeanfield(cfg, avg);
    list_latency        = [0.05 0.185; 0.185 0.28; 0.28 0.5];
    
    for t = 1:3
        lmt1                    = find(round(avg.time,3) == round(list_latency(t,1),3));
        lmt2                    = find(round(avg.time,3) == round(list_latency(t,2),3));
        data                    = squeeze(gfp.avg(lmt1:lmt2));
        ERF2Corr(sb,t)          = max(data); clear data ;
    end
    
end

clearvars -except ERF2Corr allsuj_GA ;

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};neighbours(n).neighblabel = [];
end

cfg                     = []; cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT';  cfg.clusterstatistics   = 'maxsum';
cfg.type                = 'Spearman'; 
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;    cfg.minnbchan           = 0; cfg.tail                = 0;cfg.clustertail         = 0;cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;cfg.neighbours          = neighbours;cfg.ivar                = 1;

for cnd_gfp = 1:3
    cfg.design(1,1:14)      = [ERF2Corr(:,cnd_gfp)];
    stat{cnd_gfp}    = ft_freqstatistics(cfg, allsuj_GA{:,1}); [min_p(cnd_gfp),p_val{cnd_gfp}]           = h_pValSort(stat{cnd_gfp});
end

for cnd_gfp = 1:3
    figure;
    stat{cnd_gfp}.mask                   = stat{cnd_gfp}.prob < min_p(cnd_gfp)+0.0001;
    corr2plot{cnd_gfp}.label             = stat{cnd_gfp}.label; corr2plot{cnd_gfp}.freq              = stat{cnd_gfp}.freq;
    corr2plot{cnd_gfp}.time              = stat{cnd_gfp}.time; corr2plot{cnd_gfp}.powspctrm         = stat{cnd_gfp}.rho .* stat{cnd_gfp}.mask;
    corr2plot{cnd_gfp}.dimord            = 'chan_freq_time';
    cfg = []; cfg.channel = 1; cfg.zlim   = [-1 1];  ft_singleplotTFR(cfg,corr2plot{cnd_gfp});
    title(num2str(min_p(cnd_gfp)))
end