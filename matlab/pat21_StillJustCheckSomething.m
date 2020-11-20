clear ; clc ; 

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
    nw_lst  = {'occ','aud.L','aud.R'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        cfg.frequency   = [5 15];
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg                 = [];
    cfg.parameter       = 'powspctrm';cfg.appenddim   = 'chan';
    freq                = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2]; cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg, freq);
    
    cfg                 = [];
    cfg.channel         = 2:3;
    cfg.frequency       = [8 10];
    cfg.latency         = [0.6 1.1];
    cfg.avgoverfreq     = 'yes';
    cfg.avgovertime     = 'yes';
    cfg.avgoverchan     = 'yes';
    tmp                 = ft_selectdata(cfg,freq);
    allsuj_bottom{sb,1} = tmp.powspctrm;
    
    
    cfg                 = [];
    cfg.channel         = 1;
    cfg.latency         = [0.6 1.2];
    allsuj_top{sb,1}    = ft_selectdata(cfg,freq);
    
end

clearvars -except allsuj_bottom allsuj_top;

[design,neighbours] = h_create_design_neighbours(size(allsuj_top,1),'eeg','t');clear neighbours ;

for n = 1:length(allsuj_top{1,1}.label)
    neighbours(n).label = allsuj_top{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT'; 
cfg.clusterstatistics   = 'maxsum';
cfg.type                = 'Spearman'; 
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;    cfg.minnbchan    = 0;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;cfg.neighbours       = neighbours;cfg.ivar       = 1;

cfg.design(1,1:14)      = [allsuj_bottom{:,1}];
stat                    = ft_freqstatistics(cfg, allsuj_top{:,1});
[min_p,p_val]           = h_pValSort(stat);

stat2plot  = h_plotStat(stat,0.00000000001,0.1);

for chn = 1:length(stat2plot.label)
    figure;
    cfg         =[];
    cfg.channel = chn;
    cfg.ylim    = [7 15];
    cfg.zlim    = [-3 3];
    ft_singleplotTFR(cfg,stat2plot);
end