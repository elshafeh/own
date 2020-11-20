clear ;clc ;

load ../data/yctot/gavg/LRNnDT.pe.mat

N1RTChan = {'MRC16', 'MRC17', 'MRC24', 'MRC25', 'MRC31', 'MRC32', 'MRF67', ...
    'MRO14', 'MRP23', 'MRP34', 'MRP35', 'MRP42', 'MRP43', 'MRP44', 'MRP45', ...
    'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT26'};

for sb = 1:14
    
    avg = ft_timelockgrandaverage([],allsuj{sb,:});
    cfg = []; cfg.baseline = [-0.1 0]; avg = ft_timelockbaseline(cfg,avg);
    
    for l = 1
        cfg             = []; 
        cfg.channel     = N1RTChan; 
        cfg.latency     = [0.05 0.185];
        cfg.avgoverchan = 'yes';
        slct            = ft_selectdata(cfg,avg);
        ix              = find(slct.avg == min(slct.avg));
        ERF2Corr(sb,l)  = slct.avg(ix);clear slct nw_slct ix;
    end
    
    clear avg gfp;
    
    ext         =   '.nDT.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat';
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    fname_in    = ['../data/tfr/' suj ext];
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq = rmfield(freq,'hidden_trialinfo');
    end
    
    cfg                                 = [];
    cfg.baseline                        = [-1.4 -1.3];
    cfg.baselinetype                    = 'relchange';
    freq                                = ft_freqbaseline(cfg,freq);
    
    cfg                                 = [];
    cfg.latency                         = [0.2 0.3];
    cfg.avgoverfreq                     = 'yes';
    cfg.avgovertime                     = 'yes';
    cfg.frequency                       = [50 70];
    cfg.channel                         = 1;
    allsuj_GA{sb,1}                     = ft_selectdata(cfg,freq) ; clear freq ;
     
    clearvars -except allsuj* ERF2Corr sb list* N1RTChan
    
end

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};neighbours(n).neighblabel = [];
end

cfg                     = []; cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT';  cfg.clusterstatistics   = 'maxsum';
cfg.type                = 'Spearman'; 
cfg.correctm            = 'bonferroni';
cfg.clusteralpha        = 0.05;    cfg.minnbchan           = 0; cfg.tail                = 0;cfg.clustertail         = 0;cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;cfg.neighbours          = neighbours;cfg.ivar                = 1;

for cnd_erf = 1
    cfg.design(1,1:14)                  = ERF2Corr(:,cnd_erf);
    stat{cnd_erf}                       = ft_freqstatistics(cfg, allsuj_GA{:,1}); 
    [min_p(cnd_erf),p_val{cnd_erf}]     = h_pValSort(stat{cnd_erf});
end

for cnd_erf = 1
    %     figure;
    stat{cnd_erf}.mask                   = stat{cnd_erf}.prob < 0.1;
    corr2plot{cnd_erf}.label             = stat{cnd_erf}.label; corr2plot{cnd_erf}.freq              = stat{cnd_erf}.freq;
    corr2plot{cnd_erf}.time              = stat{cnd_erf}.time; corr2plot{cnd_erf}.powspctrm         = stat{cnd_erf}.rho .* stat{cnd_erf}.mask;
    corr2plot{cnd_erf}.dimord            = 'chan_freq_time';
    %     cfg = []; cfg.zlim   = [-1 1];  ft_singleplotTFR(cfg,corr2plot{cnd_erf});
    %     title(num2str(min_p(cnd_erf)))
end