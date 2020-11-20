clear;clc;dleiftrip_addpath;

% cond = {'RnDT','LnDT','NnDT'};
cond = {'RCnD','LCnD','NCnD'};

suj_list = [1:4 8:17];

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))];
    
    for b = 1:length(cond)
        
        fname = ['../data/tfr/' suj '.' cond{b} '.all.wav.40t150Hz.m2000p2000.MinusEvoked.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        cfg                             = [];
        %         cfg.baseline                    = [-1.4 -1.3];
        cfg.baseline                    = [-0.2 -0.1];
        cfg.baselinetype                = 'relchange';
        allsuj_GA{a,b,1}                = ft_freqbaseline(cfg,freq);
        cfg.baselinetype                = 'absolute';
        allsuj_GA{a,b,2}                = ft_freqbaseline(cfg,freq);
        
        clear freq cfg
        
    end
end

clearvars -except allsuj_GA

[design,neighbours]     = h_create_design_neighbours(size(allsuj_GA,1),'meg','t'); clc;

cfg                     = [];
cfg.channel             = 'MEG';
cfg.frequency           = [60 120];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;

cfg.latency             = [-0.1 0.6];
% cfg.latency             = [-0.6 1.2];
% cfg.latency             = [-0.2 0.6];

for cnd_bsl = 1:2
    stat{cnd_bsl,1}                 = ft_freqstatistics(cfg, allsuj_GA{:,1,cnd_bsl}, allsuj_GA{:,3,cnd_bsl}); % RN
    stat{cnd_bsl,2}                 = ft_freqstatistics(cfg, allsuj_GA{:,2,cnd_bsl}, allsuj_GA{:,3,cnd_bsl}); % LN
    stat{cnd_bsl,3}                 = ft_freqstatistics(cfg, allsuj_GA{:,1,cnd_bsl}, allsuj_GA{:,2,cnd_bsl}); % RL
end

for cnd_bsl = 1:2
    for s = 1:3
        [min_p(cnd_bsl,s),p_val{cnd_bsl,s}] = h_pValSort(stat{cnd_bsl,s});
    end
end

for cnd_bsl = 1:2
    for s = 1:3
        %         stat2plot{cnd_bsl,s} = h_plotStat(stat{cnd_bsl,s},0.0000001,min_p(cnd_bsl,s)+0.000001);
        stat2plot{cnd_bsl,s} = h_plotStat(stat{cnd_bsl,s},0.0000001,0.2);
    end
end

lst_bsl = {'rel','abs'};
lst_st = {'RN','LN','RL'};

for cnd_bsl = 1:2
    for s = 1:3
        figure;
        cfg                 = [];
        cfg.layout          = 'CTF275.lay';
        cfg.zlim            = [-2 2];
        cfg.marker          = 'off';
        ft_topoplotTFR(cfg,stat2plot{cnd_bsl,s})
        title([lst_bsl{cnd_bsl} ' ' lst_st{s} ' ' num2str(min_p(cnd_bsl,s))]);
    end
end

% lst{1} = {'MLT24', 'MLT34', 'MLT35', 'MLT43', 'MLT44', 'MLT45', 'MLT52', 'MLT53', 'MLT54'};
% lst{2} = {'MLO12', 'MLO22', 'MLO23', 'MLO24', 'MLO31', 'MLO32', 'MLO33', 'MLO34', 'MLO42', 'MLO43', 'MLO44', 'MLO53', 'MLT47', 'MLT57'};
% for l = 1:2
% subplot(2,1,l)
% plot(stat2plot{2}.time,mean(squeeze(stat2plot{2}.powspctrm(h_indx_tf_labels(lst{l}),1,:)),1));
% end

% for l = 1:2
%     subplot(2,1,l)
%     plot(stat2plot{1}.freq,mean(squeeze(stat2plot{1}.powspctrm(h_indx_tf_labels(lst{l}),:,1)),1));
% end