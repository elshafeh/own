clear ; clc ; close all ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list    = {'DIS','fDIS'};
    ext1        = '.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat';
    
    for d = 1:2
        fname_in = ['../data/tfr/' suj '.'  cnd_list{d} ext1 ];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        if isfield(freq,'hidden_trialinfo')
            freq = rmfield(freq,'hidden_trialinfo');
        end
        
        gavg_sin{d}         = freq ;
        
        cfg                 = [];
        cfg.frequency       = [50 100];
        cfg.latency         = [0.1 0.5];
        cfg.channel         = 2;
        allsuj_GA{sb,d}     = ft_selectdata(cfg,freq) ; clear freq ;
        
    end
    
end

clearvars -except allsuj_GA gavg_sin;

[design,neighbours] = h_create_design_neighbours(14,'eeg','t');

neighbours = [];

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;cfg.design              = design;
cfg.neighbours          = neighbours;cfg.uvar                = 1;cfg.ivar                = 2;
cfg.minnbchan           = 0;
stat                    = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});

[min_p,p_val]           = h_pValSort(stat);
stat2plot               = h_plotStat(stat,0.05);

cfg                     = [];
cfg.parameter           = 'powspctrm'; cfg.operation  = 'x1-x2';
gavg                    = ft_math(cfg,ft_freqgrandaverage([],gavg_sin{:,1}),ft_freqgrandaverage([],gavg_sin{:,2}));
cfg                     = []; cfg.channel = 2; gavg = ft_selectdata(cfg,gavg);

f0      = stat.freq(1);f1      = stat.freq(end);
t0      = stat.time(1);t1      = stat.time(end);

zlim ='maxabs';
tf_masked(gavg,stat,f0, f1,t0,t1,'audR',0.6,0.1,zlim);
vline(0,'--k');
vline(0.3,'--k');
xlim([-0.1 0.5]);
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')
title('');

% plot(stat2plot.freq,squeeze(stat2plot.powspctrm));
% figure;
% for chn = 1:length(stat2plot.label)
%     subplot(1,1,chn)
%     cfg             = [];
%     cfg.channel     = chn;
%     cfg.zlim        = [-4 4];
%     ft_singleplotTFR(cfg,stat2plot);clc;
% end