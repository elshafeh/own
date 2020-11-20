clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.all.wav.NewEvoked.1t20Hz.m3000p3000.mat';
    fname_in    =   ['../data/tfr/' suj '.'  ext1];
    
    fprintf('Loading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq    = rmfield(freq,'hidden_trialinfo');
    end
    
    nw_chn  = [1 2;3 5; 4 6];
    nw_lst  = {'occ.L','aud.L','aud.R'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        cfg.frequency   = [5 15];
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = [];
    cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
    freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                                     = [];
    cfg.latency                             = [0 1.8];
    allsuj{sb,1}                             = ft_selectdata(cfg, freq);
    
    cfg                                     = [];
    bsl_period                              = [-0.6 -0.2];
    cfg.latency                             = bsl_period;
    cfg.avgovertime                         = 'yes';
    bslRptAvg                               = ft_selectdata(cfg, freq);
    allsuj{sb,2}                             = allsuj{sb,1};
    allsuj{sb,2}.powspctrm                   = repmat(bslRptAvg.powspctrm,1,1,size(allsuj{sb,1}.powspctrm,3));
    
    for cnd = 1:2
        
        occAvg      = squeeze(allsuj{sb,cnd}.powspctrm(1,:,:));
        audLPow     = squeeze(allsuj{sb,cnd}.powspctrm(2,:,:));
        audRPow     = squeeze(allsuj{sb,cnd}.powspctrm(3,:,:));
        
        tmp(1,:,:) = (audLPow-occAvg) ./ squeeze(mean(cat(3,audLPow,occAvg),3));
        tmp(2,:,:) = (audRPow-occAvg) ./ squeeze(mean(cat(3,audRPow,occAvg),3));
        
        allsuj{sb,cnd}.powspctrm = tmp ; clear tmp ;
        allsuj{sb,cnd}.label     = {'audL.occAv','audR.occAv'};

    end
    
    cfg                 = [];
    cfg.operation       = 'x1-x2';
    cfg.parameter       = 'powspctrm';
    allsuj_index{sb,1}  = ft_math(cfg,allsuj{sb,1},allsuj{sb,2});
    
    load ../data/yctot/rt/rt_CnD_adapt.mat ;
    
    allsuj_rt{sb,1}     = median(rt_all{sb});
    allsuj_rt{sb,2}     = mean(rt_all{sb});
    
end

clearvars -except allsuj_index allsuj_rt;     

[design,neighbours] = h_create_design_neighbours(size(allsuj_index,1),'eeg','t');clear neighbours ;

for n = 1:length(allsuj_index{1,1}.label)
    neighbours(n).label = allsuj_index{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT'; 
cfg.clusterstatistics   = 'maxsum';
cfg.type                = 'Spearman'; 
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;    cfg.minnbchan           = 0;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;cfg.neighbours          = neighbours;cfg.ivar                = 1;

for cnd_rt = 1:2
    cfg.design(1,1:14)                      = [allsuj_rt{:,cnd_rt}];
    stat{cnd_rt}                            = ft_freqstatistics(cfg, allsuj_index{:,1}); 
    [min_p(cnd_rt),p_val{cnd_rt}]           = h_pValSort(stat{cnd_rt});
end

for chn = 1:2
    stat2plot{chn}   = h_plotStat(stat{chn},0.00000000001,0.05);
end

for cnd_s = 1:2
    for chn = 1:2
        figure;
        cfg         =[];
        cfg.channel = chn;
        cfg.ylim    = [7 15];
        cfg.zlim    = [-3 3];
        ft_singleplotTFR(cfg,stat2plot{cnd_s});
    end
end