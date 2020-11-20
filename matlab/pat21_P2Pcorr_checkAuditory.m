clear;clc;dleiftrip_addpath;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext1        =   'CnD.SomaGammaNoAVGCoVm800p2000msfreq1t120Hz.all.wav.pow.4t120Hz.m3000p3000.mat';
    fname_in    =   ['../data/tfr/' suj '.'  ext1];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq    = rmfield(freq,'hidden_trialinfo');
    end
    
    nw_chn  = [61 62 149 150;63 64 151 152];
    nw_lst  = {'aud Left','aud Right'};
    
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
    
    act_period      = [0 1.2];
    bsl_period      = [-0.6 -0.2];
    frq_intrst      = [7 15];
    
    %     bsl_period                              = [-0.4 -0.2];
    %     frq_intrst                              = [15 50];
    %     bsl_period                              = [-0.2 -0.1];
    %     frq_intrst                              = [40 120];
    %     chn_intrst                              = [61:64 149:152];
    
    cfg                                     = [];
    cfg.frequency                           = frq_intrst;
    %     cfg.channel                             = chn_intrst;
    freq                                    = ft_selectdata(cfg,freq);
    
    cfg                                     = [];
    cfg.latency                             = act_period;
    allsuj_activation{a}                    = ft_selectdata(cfg, freq);
    
    cfg                                     = [];
    cfg.latency                             = bsl_period;
    cfg.avgovertime                         = 'yes';
    allsuj_baselineAvg{a}                   = ft_selectdata(cfg, freq);
    allsuj_baselineRep{a}                   = allsuj_activation{a};
    allsuj_baselineRep{a}.powspctrm         = repmat(allsuj_baselineAvg{a}.powspctrm,1,1,size(allsuj_activation{a}.powspctrm,3));
    
end

clearvars -except allsuj_* gavg_suj

[design,neighbours]     = h_create_design_neighbours(length(allsuj_activation),allsuj_activation{1,1},'virt','t');

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
% cfg.clusterstatistic    = 'maxsum';
% cfg.correctm            = 'cluster';
% cfg.minnbchan           = 0;
% cfg.clustertail         = 0;
% cfg.neighbours          = neighbours;
% cfg.clusteralpha        = 0.05;
cfg.correctm            = 'bonferroni';
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;
stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});
stat2plot               = h_plotStat(stat,0.000000000000000000000000001,0.05);

stat2plot.powspctrm(stat2plot.powspctrm>0) = 0;

for chn = 1:length(stat2plot.label)
    subplot(2,1,chn)
    cfg             =[];
    cfg.channel     = chn;
    cfg.zlim        = [-4 4];
    ft_singleplotTFR(cfg,stat2plot);clc;
end

figure;
hold on
for chn = 1:length(stat2plot.label)
    pow = squeeze(mean(stat2plot.powspctrm(chn,:,:),3));
    plot(stat2plot.freq,pow,'LineWidth',2);
    xlim([stat2plot.freq(1) stat2plot.freq(end)])
    ylim([-4 4])
    hline(0,'--k');
end
legend(stat2plot.label);

figure;
hold on
for chn = 1:length(stat2plot.label)
    f1  = find(round(stat2plot.freq) == 8);
    f2  = find(round(stat2plot.freq) == 11);
    pow = squeeze(mean(stat2plot.powspctrm(chn,f1:f2,:),2));
    plot(stat2plot.time,pow,'LineWidth',2);
    xlim([stat2plot.time(1) stat2plot.time(end)])
    ylim([-4 4])
    hline(0,'--k');
    ix  = find(pow==min(pow));
    vline(stat2plot.time(ix),'-k',[num2mstr(round(stat2plot.time(ix)*1000)) 'ms']);
end
legend(stat2plot.label);