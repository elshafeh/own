clear ; clc ; dleiftrip_addpath;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    lst_cue     = {'R','L','N'};
    ext1        = 'CnD.SomaGammaNoAVGCoVm800p2000msfreq1t120Hz.all.wav.pow.4t120Hz.m3000p3000.mat';
    
    for ncond = 1:3
        
        fname_in    =   ['../data/tfr/' suj '.'  lst_cue{ncond} ext1];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo')
            freq    = rmfield(freq,'hidden_trialinfo');
        end
        
        frq_band            = [7 15];
        bsl_band            = [-0.6 -0.2];
        
        cfg                 = [];
        cfg.baseline        = bsl_band;
        cfg.baselinetype    = 'relchange';
        
        cfg                 = [];
        cfg.frequency       = frq_band;
        cfg.latency         = [0 1.2];
        allsuj_GA{sb,ncond} = ft_selectdata(cfg,freq);
        
    end
end

clearvars -except allsuj_GA ;

[design,neighbours]     = h_create_design_neighbours(length(allsuj_GA),allsuj_GA{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'fdr'; %cluster
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

stat{1}                 = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
stat{2}                 = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,3});
stat{3}                 = ft_freqstatistics(cfg, allsuj_GA{:,2}, allsuj_GA{:,3});

for nstat = 1:length(stat)
    [min_p(nstat),p_val{nstat}] = h_pValSort(stat{nstat});
    stat2plot{nstat} = h_plotStat(stat{nstat},0.000000001,0.05/3);
end

lst_st = {'RL','RL','LN'};

for nstat = 1:length(stat)
    for chn = 1:length(stat2plot{nstat}.label)
        
        if mean(mean(squeeze(stat2plot{nstat}.powspctrm(chn,:,:)))) ~= 0
            
            figure;
            
            if size(stat2plot{nstat}.powspctrm,3) > 1
                cfg             =[];
                cfg.channel     = chn;
                cfg.zlim        = [-5 5];
                ft_singleplotTFR(cfg,stat2plot{nstat});clc;
                title([lst_st{nstat} ' ' stat2plot{nstat}.label{chn}])
                vline(0,'--k');
                vline(0.6,'--k');
                %                 vline(1.2,'--k');
                saveas(gcf,['../images/soma.virtual/alpha_compare/' [lst_st{nstat} ' ' stat2plot{nstat}.label{chn}] '.png']);
                close all;
            end
        end
    end
end