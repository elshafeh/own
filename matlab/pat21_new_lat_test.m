clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','NR','NL'};
    
    for cnd = 1:length(lst_cnd)
        
        %         ext1        =   [lst_cnd{cnd} 'CnD.all.wav.1t7Hz.m4000p4000.MinusEvoked.mat'];
        ext1        =   [lst_cnd{cnd} 'CnD.all.wav.14t50Hz.m2000p2000.MinusEvoked.mat'];

        fname_in    =   ['../data/tfr/' suj '.'  ext1];
        
        fprintf('\nLoading %50s \n',fname_in); load(fname_in);
        
        if isfield(freq,'hidden_trialinfo')
            freq    = rmfield(freq,'hidden_trialinfo');
        end
        
        %         carr{cnd} = freq;
        
        cfg                             = [];
        cfg.baseline                    = [-0.4 -0.2];
        cfg.baselinetype                = 'relchange';
        allsuj{sb,cnd}                  = ft_freqbaseline(cfg,freq); clear freq ;
        
    end
    
    %     for cnd = 1:2
    %         allsuj{sb,cnd}              = carr{cnd};
    %         actv                        = carr{cnd}.powspctrm;
    %         bsl                         = carr{cnd+2}.powspctrm;
    %         allsuj{sb,cnd}.powspctrm    = (actv-bsl)./bsl;
    %     end
    
end

clearvars -except allsuj ;

[design,neighbours]     = h_create_design_neighbours(14,allsuj{1,1},'meg','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;cfg.tail                = 0;cfg.clustertail         = 0;cfg.numrandomization    = 1000;cfg.design              = design;
cfg.neighbours          = neighbours;cfg.uvar                = 1;cfg.ivar                = 2;
cfg.minnbchan           = 3;
cfg.latency             = [-0.1 1.2];

% cfg.frequency           = [2 7];

stat{1}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2});
stat{2}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,3});
stat{3}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,4});
stat{4}                 = ft_freqstatistics(cfg, allsuj{:,2}, allsuj{:,3});
stat{5}                 = ft_freqstatistics(cfg, allsuj{:,2}, allsuj{:,4});
stat{6}                 = ft_freqstatistics(cfg, allsuj{:,3}, allsuj{:,4});

for cnd_s = 1:length(stat)
    [min_p(cnd_s),p_val{cnd_s}]     = h_pValSort(stat{cnd_s});
end

for cnd_s = 1:length(stat)
    stat2plot{cnd_s} = h_plotStat(stat{cnd_s},0.00000001,0.11);
end

lst_contrast = {'RvL','RvNR','RvNL','LvNR','LvNL','NRvNL'};

for cnd_s = 1:length(stat)
    figure;
    cfg              = [];
    cfg.layout       = 'CTF275.lay';
    %     cfg.xlim         = -0.1:0.1:1.2;
    cfg.zlim         = [-1 1];
    ft_topoplotTFR(cfg,stat2plot{cnd_s});clc;
    title([lst_contrast{cnd_s} ' ' num2str(min_p(cnd_s))])
end