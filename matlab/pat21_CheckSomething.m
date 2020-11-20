clear ; clc ; dleiftrip_addpath ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
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
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = [];
    cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
    freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                                     = [];
    cfg.latency                             = [0.6 1.2];
    allsuj{a,1}                             = ft_selectdata(cfg, freq);
    
    cfg                                     = [];
    bsl_period                              = [-0.6 -0.2];
    cfg.latency                             = bsl_period;
    cfg.avgovertime                         = 'yes';
    bslRptAvg                               = ft_selectdata(cfg, freq);
    allsuj{a,2}                             = allsuj{a,1};
    allsuj{a,2}.powspctrm                   = repmat(bslRptAvg.powspctrm,1,1,size(allsuj{a}.powspctrm,3));
    
    for cnd = 1:2
        
        occAvg      = squeeze(allsuj{a,cnd}.powspctrm(1,:,:));
        audLPow     = squeeze(allsuj{a,cnd}.powspctrm(2,:,:));
        audRPow     = squeeze(allsuj{a,cnd}.powspctrm(3,:,:));
        
        tmp(1,:,:) = (audLPow-occAvg) ./ squeeze(mean(cat(3,audLPow,occAvg),3));
        tmp(2,:,:) = (audRPow-occAvg) ./ squeeze(mean(cat(3,audRPow,occAvg),3));
        
        allsuj{a,cnd}.powspctrm = tmp ; clear tmp ;
        allsuj{a,cnd}.label     = {'audL.occAv','audR.occAv'};

    end
    
end

clearvars -except allsuj

[design,neighbours] = h_create_design_neighbours(size(allsuj,1),'eeg','t');clear neighbours ;

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.minnbchan           = 0;cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours          = neighbours;cfg.uvar                = 1;cfg.ivar                = 2;
cfg.frequency           = [5 15] ;

for chn = 1:length(allsuj{1,1}.label)
    cfg.channel                         = chn ;
    stat{chn}                           = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2});
    [min_p(chn,1),p_val{chn}]             = h_pValSort(stat{chn});
end

for chn = 1:length(allsuj{1,1}.label)
    stat2plot{chn}   = h_plotStat(stat{chn},0.00000000001,0.05);
end

for chn = 1:length(stat2plot)
        figure;
        cfg             = [];
        cfg.zlim        = [-4 4];
        ft_singleplotTFR(cfg,stat2plot{chn});clc;
end