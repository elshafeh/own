clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.KTPlanar.wav.5t18Hz.m3p3.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    data_sub                    = ft_freqbaseline(cfg,freq);
    
    clear freq fname suj
    
    cfg                 = [];
    cfg.latency         = [0.6 1];
    cfg.frequency       = [8 10];
    cfg.avgovertime     = 'yes';
    cfg.avgoverfreq     = 'yes';
    tmp                 = ft_selectdata(cfg,data_sub);
    
    data                = squeeze(tmp.powspctrm);
    
    rho                 = corr(data,rt_all{sb} , 'type', 'Spearman');
    rhoF                = .5.*log((1+rho)./(1-rho));
    
    tmp.powspctrm = rhoF ;
    tmp.dimord    = 'chan_freq';
    
    tmp.freq      = frq_list(f);
    
    tmp = rmfield(tmp,'time');
    tmp = rmfield(tmp,'trialinfo');
    tmp = rmfield(tmp,'cfg');
    
    allsuj{sb,1}                = tmp ;
    allsuj{sb,2}                = tmp ;
    allsuj{sb,2}.powspctrm(:,:) = 0 ;
    
    clear tmp data
    
end


clearvars -except allsuj*;

cfg                   = [];
cfg.channel           = 'MEG';
cfg.method            = 'montecarlo';
cfg.statistic         = 'depsamplesT';
cfg.correctm          = 'cluster';
cfg.clusteralpha      = 0.05;             % First Threshold %
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 2;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.design            = design;
cfg.uvar              = 1;
cfg.ivar              = 2;
stat                  = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2});