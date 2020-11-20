clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    cnd_list                        = {'m1100m100ms','p100p1100ms'};
    
    for cnd = 1:2
        
        ext_essai   = ['SomaAuditoryVisual.5t20.with.25t120.' cnd_list{cnd} '.mi.mat'];
        
        fprintf('Loading %s\n',['../data/tfr/' suj '.' ext_essai])
        load(['../data/tfr/' suj '.' ext_essai]);
        
        allsuj_GA{sb,cnd}.powspctrm       = squeeze(mean(crossfreq.crsspctrm,1));
        %     allsuj_GA{sb,2}.powspctrm       = allsuj_GA{sb,1}.powspctrm;
        %     allsuj_GA{sb,2}.powspctrm(:)    = 0;
        
        
        allsuj_GA{sb,cnd}.freq      = crossfreq.freqlow;
        allsuj_GA{sb,cnd}.time      = crossfreq.freqhigh;
        allsuj_GA{sb,cnd}.label     = crossfreq.label;
        allsuj_GA{sb,cnd}.dimord    = 'chan_freq_time';
        
    end
    
    %     big_gavg(sb,:,:,:)  = squeeze(mean(crossfreq.crsspctrm,1));
    %     big_lofr            = crossfreq.freqlow;
    %     big_hifr            = crossfreq.freqhigh;
    %     big_labl            = crossfreq.label;
    
end

clearvars -except allsuj_GA

% big_gavg = squeeze(mean(big_gavg,1));
%
% for chn = 1:size(big_labl,1)
%     subplot(3, 4, chn);
%     imagesc(big_lofr,big_hifr,squeeze(big_gavg(chn,:,:)),[0.463 0.468]);
%     axis xy
%     title(big_labl{chn})
% end

[design,neighbours] = h_create_design_neighbours(length(allsuj_GA),allsuj_GA{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'bonferroni'; % cluster ; fdr
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
stat                    = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
stat                    = rmfield(stat,'cfg');
[min_p,p_val]           = h_pValSort(stat);
p_lim                   = 0.05;
stat2plot               = h_plotStat(stat,0.000000000000000001,p_lim);

% [min(min(min(stat2plot.powspctrm))) max(max(max(stat2plot.powspctrm)))]

% stat2plot.powspctrm     = squeeze(stat2plot.powspctrm)/10000;

% [min(min(min(stat2plot.powspctrm))) max(max(max(stat2plot.powspctrm)))]

i = 0 ;

for chn = [3 4 11 12] %1:length(stat2plot.label)
    i = i + 1;
    subplot(2,2,i)
    
    cfg                 =[];
    cfg.channel         = chn;
    cfg.zlim            = [-6 6];
    ft_singleplotTFR(cfg,stat2plot);
    
    clc;
    
end