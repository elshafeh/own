clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'R','L','N'};
    
    for cnd = 1:length(cnd_list)
        
        fname_in = ['../data/tfr/' suj '.'  cnd_list{cnd} 'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.all.wav.1t20Hz.m3000p3000..mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        freq        = rmfield(freq,'hidden_trialinfo');
        
        nw_chn      = [1 1;2 2;3 5;4 6];
        nw_lst      = {'occL','occR','audL','audR'};
        
        for l = 1:length(nw_lst)
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
        freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        
        cfg                 = [];
        cfg.baseline        = [-0.6 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        cfg             = [];
        cfg.latency     = [0.6 1.2];
        cfg.frequency   = [7 15];
        allsuj{sb,cnd}  = ft_selectdata(cfg,freq) ;clear freq;
        
    end
end

clearvars -except allsuj ;

[design,neighbours] = h_create_design_neighbours(14,'eeg','a'); clc;

neighbours = [];

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesFunivariate';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;cfg.minnbchan           = 0;
cfg.tail                = 0;cfg.clustertail         = 0;cfg.design              = design;cfg.clustercritval      = 0.05;cfg.neighbours          = neighbours;cfg.uvar                = 1;cfg.ivar                = 2;
cfg.numrandomization    = 1000;
stat                    = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2}, allsuj{:,3});
[min_p,p_val]           = h_pValSort(stat);
stat2plot               = h_plotStat(stat,1);

for chn = 1:4
    subplot(2,2,chn)
    cfg             = [];
    cfg.channel     = chn;
    cfg.zlim        = [-4 4];
    ft_singleplotTFR(cfg,stat2plot);
end