clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group      = suj_group(3);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                             = suj_list{sb};
        suj_list                        = suj_group{ngroup};
        
        ext_tfr                         = 'waveletPOW.40t150Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat'; %'waveletPOW.1t20Hz.m1000p1000.50Mstep.AvgTrials.MinEvoked.mat'; %   
        ext_data                        = '../data/dis_sensor_data/';
        
        fname_in                        = [ext_data suj '.2DIS.' ext_tfr];
        
        fprintf('Loading %50s\n',fname_in);
        load(fname_in); act_freq = freq ; clear freq ;
        
        fname_in                        = [ext_data suj '.2fDIS.' ext_tfr];
        
        fprintf('Loading %50s\n',fname_in);
        load(fname_in); bsl_freq = freq ; clear freq;
        
        freq                            = act_freq;
        freq.powpsctrm                  = act_freq.powspctrm - bsl_freq.powspctrm;
        
        if isfield(freq,'check_trialinfo')
            freq    = rmfield(freq,'check_trialinfo');
        end
        
        cfg                             = [];
        cfg.latency                     = [0.1 0.3]; % [0.35 0.65]; % 
        cfg.frequency                   = [60 100]; %[7 15]; % 
        cfg.avgoverfreq                 = 'yes';
        cfg.avgovertime                 = 'yes';
        freq                            = ft_selectdata(cfg,freq);
        
        allsuj_data{ngroup}{sb,1}       = freq;
        
        [capture_median,capture_mean,tdown_median,tdown_mean,arousal_median,arousal_mean] = create_rt_corr(suj);
        
        allsuj_behav{ngroup}{sb,1}      = capture_median;
        allsuj_behav{ngroup}{sb,2}      = capture_mean;
        allsuj_behav{ngroup}{sb,3}      = tdown_median;
        allsuj_behav{ngroup}{sb,4}      = tdown_mean;
        allsuj_behav{ngroup}{sb,5}      = arousal_median;
        allsuj_behav{ngroup}{sb,6}      = arousal_mean;
        
        clearvars -except sb allsuj_behav allsuj_data suj_list ngroup suj_group; clc;
        
    end
end

clearvars -except allsuj_behav allsuj_data

for ngroup = 1:length(allsuj_data)
    
    [~,neighbours]                          = h_create_design_neighbours(size(allsuj_data{ngroup},1),allsuj_data{ngroup}{1},'meg','t'); clc;
    
    for ntest = 1:size(allsuj_behav{ngroup},2)
        
        cfg                                 = [];
        cfg.method                          = 'montecarlo';
        cfg.statistic                       = 'ft_statfun_correlationT';
        cfg.correctm                        = 'cluster';
        cfg.clusterstatistics               = 'maxsum';
        cfg.clusteralpha                    = 0.05; % !! !! !!
        cfg.minnbchan                       = 2;
        cfg.neighbours                      = neighbours;
        cfg.tail                            = 0;
        cfg.clustertail                     = 0;
        cfg.alpha                           = 0.025;
        cfg.numrandomization                = 1000;
        cfg.ivar                            = 1;
        
        cfg.type                            = 'Spearman';
        
        nsuj                                = size(allsuj_behav{ngroup},1);
        cfg.design(1,1:nsuj)                = [allsuj_behav{ngroup}{:,ntest}];
        
        stat{ngroup,ntest}                  = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,1});
        
    end
end

clearvars -except allsuj_behav allsuj_data stat;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}] = h_pValSort(stat{ngroup,ntest});
    end
end

clearvars -except allsuj_behav allsuj_data stat min_p p_val;

list_test           = {'capture median','capture mean','tdown median','tdown mean','arousal median','arousal mean'};

for ngroup = 1:size(stat,1)
    
    figure;
    i = 0 ;
    
    for ntest = 1:size(stat,2)
        
        stoplot                 = stat{ngroup,ntest};
        stoplot.mask            = stoplot.prob < 0.2;
        
        corr2plot.label         = stoplot.label;
        corr2plot.freq          = stoplot.freq;
        corr2plot.time          = stoplot.time;
        corr2plot.powspctrm     = stoplot.rho .* stoplot.mask;
        corr2plot.dimord        = stoplot.dimord;
        
        i                       = i+1 ;
        
        subplot(1,6,i)
        
        cfg                     = [];
        cfg.comment             = 'no';
        cfg.marker              = 'off';
        cfg.layout              = 'CTF275.lay';
        cfg.zlim                = [-0.3 0.3];
        ft_topoplotTFR(cfg,corr2plot);
        
        title([list_test{ntest} ' p = ' num2str(min_p(ngroup,ntest))])
        
    end
end