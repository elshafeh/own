clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/Concat_DisfDis.pe.mat ;

for sb = 1:14
    
    suj_list            = [1:4 8:17];
    suj                 = ['yc' num2str(suj_list(sb))];
    
    ext1                =   '.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat' ;
    lst_dis             =   {'DIS','fDIS'};
    
    for cnd_dis = 1:2
        
        fname_in    = ['../data/tfr/' suj '.' lst_dis{cnd_dis} ext1];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo')
            freq        = rmfield(freq,'hidden_trialinfo');
        end
        
        cfg                         = [];
        cfg.channel                 = 2;
        tf_dis{cnd_dis}             = ft_selectdata(cfg,freq); clear freq ;
    end
    
    cfg                         = [];
    cfg.parameter               = 'powspctrm'; cfg.operation  = 'x1-x2';
    freq                        = ft_math(cfg,tf_dis{1},tf_dis{2}); clear tf_dis ;
    
    twin                        = 0.05;
    tlist                       = 0:twin:0.6-twin;
    ftap                        = 10;
    flist                       = 50:ftap:90;
    chn_vctor                   = 1;
    nwspctrm                    = h_newspctr(freq,twin,tlist,ftap,flist,chn_vctor);
    
    allsuj_GA{sb,1}.powspctrm   = nwspctrm;
    allsuj_GA{sb,1}.time        = tlist;
    allsuj_GA{sb,1}.freq        = flist;
    allsuj_GA{sb,1}.dimord      = freq.dimord;
    allsuj_GA{sb,1}.label       = freq.label(chn_vctor);clear nwspctrm freq;
    
    cfg                 = [];
    cfg.parameter       = 'avg';
    cfg.operation       = 'subtract';
    avg                 = ft_math(cfg,allsuj{sb,1},allsuj{sb,2});
    
    cfg                 = [];
    cfg.method          = 'amplitude';
    gfp                 = ft_globalmeanfield(cfg, avg);
    list_latency        = [0.06 0.16; 0.16 0.37; 0.37 0.47; 0.47 0.55];
    
    for t = 1:4
        lmt1                    = find(round(avg.time,3) == round(list_latency(t,1),3));
        lmt2                    = find(round(avg.time,3) == round(list_latency(t,2),3));
        data                    = squeeze(gfp.avg(lmt1:lmt2));
        ERF2Corr(sb,t)          = max(data); clear data ;
    end
    
    clearvars -except allsuj ERF2Corr allsuj_GA sb
end

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};neighbours(n).neighblabel = [];
end

cfg                     = []; cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT';  cfg.clusterstatistics   = 'maxsum';
cfg.type                = 'Spearman'; 
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;    cfg.minnbchan           = 0; cfg.tail                = 0;cfg.clustertail         = 0;cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;cfg.neighbours          = neighbours;cfg.ivar                = 1;

for cnd_gfp = 1:4
    cfg.design(1,1:14)                          = ERF2Corr(:,cnd_gfp);
    stat{cnd_gfp}                               = ft_freqstatistics(cfg, allsuj_GA{:,1}); 
    [min_p(cnd_gfp),p_val{cnd_gfp}]             = h_pValSort(stat{cnd_gfp});
end

for cnd_gfp = 1:4
    figure;
    stat{cnd_gfp}.mask                   = stat{cnd_gfp}.prob < min_p(cnd_gfp)+0.0001;
    corr2plot{cnd_gfp}.label             = stat{cnd_gfp}.label; corr2plot{cnd_gfp}.freq              = stat{cnd_gfp}.freq;
    corr2plot{cnd_gfp}.time              = stat{cnd_gfp}.time; corr2plot{cnd_gfp}.powspctrm         = stat{cnd_gfp}.rho .* stat{cnd_gfp}.mask;
    corr2plot{cnd_gfp}.dimord            = 'chan_freq_time';
    cfg = []; cfg.channel = 1; cfg.zlim   = [-1 1];  ft_singleplotTFR(cfg,corr2plot{cnd_gfp});
    title(num2str(min_p(cnd_gfp)))
end