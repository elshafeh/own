clear ; clc ; dleiftrip_addpath ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext1        =   'CnD.CombinedRois4GammaCoVm800p2000msfreq1t120Hz.all.wav.pow.4t120Hz.m3000p3000.mat';
    fname_in    =   ['../data/tfr/' suj '.'  ext1];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq    = rmfield(freq,'hidden_trialinfo');
    end
    
    cfg                                     = [];
    cfg.baseline                            = [-0.2 -0.1];
    cfg.baselinetype                        = 'relchange';
    freq                                    = ft_freqbaseline(cfg,freq);
    
    cfg                                     = [];
    cfg.latency                             = [0 1.1];
    allsuj_activation{a}                    = ft_selectdata(cfg, freq);
    
    allsuj_baselineRep{a}                   = allsuj_activation{a};
    allsuj_baselineRep{a}.powspctrm(:,:,:)  = 0;

    clear freq
    
end

clearvars -except allsuj_* gavg_suj

[design,neighbours] = h_create_design_neighbours(length(allsuj_activation),allsuj_activation{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';

% cfg.correctm            = 'fdr';
% cfg.correctm            = 'cluster';
% cfg.correctm            = 'bonferroni';

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
cfg.frequency           = [40 120];
stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});
stat                    = rmfield(stat,'cfg');
[min_p,p_val]           = h_pValSort(stat);

p_lim                   = 0.05;
stat2plot               = h_plotStat(stat,0.000000000000000001,p_lim);
stat2plot.powspctrm     = squeeze(stat2plot.powspctrm);

for chn = 1:length(stat2plot.label)
    if mean(mean(squeeze(stat2plot.powspctrm(chn,:,:)))) ~= 0
        figure;
        
        if size(stat2plot.powspctrm,3) > 1
            cfg             =[];
            cfg.channel     = chn;
            cfg.zlim        = [-4 4];
            ft_singleplotTFR(cfg,stat2plot);
        else
            
            plot(stat2plot.time,squeeze(stat2plot.powspctrm(chn,:)),'LineWidth',4);
            xlim([stat2plot.time(1) stat2plot.time(end)]);
            ylim([-5 5]);
            title(stat2plot.label{chn})
            
        end
    end
    clc;
end