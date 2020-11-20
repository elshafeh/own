% Run Non-parametric cluster based permutation tests against baseline

clear ; clc ; dleiftrip_addpath ; close all ; 

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/tfr/' suj '.DIS.all.wav.1t100Hz.m3000p3000.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    allsuj_activation{sb,1}              = freq;
    
    cfg                     = [];
    cfg.baseline            = [-0.4 -0.2];
    cfg.baselinetype        = 'relchange';
    allsuj_activation{sb,2} = ft_freqbaseline(cfg,freq);
    cfg.baselinetype        = 'absolute';
    allsuj_activation{sb,3} = ft_freqbaseline(cfg,freq);
    
    clear freq
    
    fname = ['../data/tfr/' suj '.fDIS.all.wav.1t100Hz.m3000p3000.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    allsuj_baselineRep{sb,1}              = freq;
    
    cfg                      = [];
    cfg.baseline             = [-0.4 -0.2];
    cfg.baselinetype         = 'relchange';
    allsuj_baselineRep{sb,2} = ft_freqbaseline(cfg,freq);
    cfg.baselinetype         = 'absolute';
    allsuj_baselineRep{sb,3} = ft_freqbaseline(cfg,freq);
    
    clear freq
    
end

clearvars -except allsuj_* ;

f_list = [4 7;8 15; 16 30;30 50;50 90];

[design,neighbours] = h_create_design_neighbours(14,'meg','t'); clc;

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [-0.2 0.6];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
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

for cnd_bsl = 1:3
    for cnd_f = 1:length(f_list)
        cfg.frequency        = [f_list(cnd_f,1) f_list(cnd_f,2)];
        stat{cnd_bsl,cnd_f}  = ft_freqstatistics(cfg, allsuj_activation{:,cnd_bsl}, allsuj_baselineRep{:,cnd_bsl});
        stat{cnd_bsl,cnd_f}  = rmfield(stat{cnd_bsl,cnd_f},'cfg');
        [min_p(cnd_bsl,cnd_f) , p_val{cnd_bsl,cnd_f}]         = h_pValSort(stat{cnd_bsl,cnd_f}) ;
        
    end
end

clearvars -except allsuj_*  ext_bsl cond stat min_p  p_val stat2plot;

list_bsl  = {'noBSL','relBSL','absBSL'};
list_freq = {'theta','alpha','beta','low gamma','high gamma'};

p_lim = 0.07;

for cnd_bsl =1:size(stat,1)
    for cnd_f = 1:size(stat,2)
        stat2plot{cnd_bsl,cnd_f}   = h_plotStat(stat{cnd_bsl,cnd_f},p_lim,'no');
        [min_p(cnd_bsl,cnd_f) , p_val{cnd_bsl,cnd_f}]         = h_pValSort(stat{cnd_bsl,cnd_f}) ;
        
    end
end

for cnd_f = 1
    for cnd_bsl = 1
        if min_p(cnd_bsl,cnd_f) < p_lim
            figure;
            cfg         =   [];
            cfg.xlim    =   -0.2:0.1:0.6;
            cfg.zlim    =   [-5 5];
            cfg.layout  = 'CTF275.lay';
            ft_topoplotTFR(cfg,stat2plot{cnd_bsl,cnd_f});
            title([list_bsl{cnd_bsl} ' ' list_freq{cnd_f}])
        end
    end
end

% plot in frequency
close all;
for cnd_f = 4
    for cnd_bsl = 1:size(stat,1)
        if min_p(cnd_bsl,cnd_f) < p_lim
            
            i = 0 ;
            
            figure;
            
            for f = 30:2:50
                
                i = i + 1 ;
                
                subplot(4,3,i)
                
                cfg         =   [];
                cfg.ylim    =   [f f+1];
                cfg.zlim    =   [-0.2 0.2];
                cfg.layout  = 'CTF275.lay';
                ft_topoplotTFR(cfg,stat2plot{cnd_bsl,cnd_f});
                title([list_bsl{cnd_bsl} ' ' list_freq{cnd_f}])

            end
        end
    end
end