clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fprintf('Loading data for %s\n',suj);
    fname_in         = ['../data/tfr/' suj '.CnD.RamaBigCov.4TimeWin1Pdc2Grang.mat'];
    load(fname_in);
    
    for nt = 1:4
        for nc = 1:2
            allsuj_GA{sb,nt,nc}             = conn_pdc{nt,nc};
            allsuj_GA{sb,nt,nc}.powspctrm   = allsuj_GA{sb,nt,nc}.pdcspctrm;
            allsuj_GA{sb,nt,nc}             = rmfield(allsuj_GA{sb,nt,nc},'pdcspctrm');
        end
    end
    
    clear conn_pdc
    
end

clearvars -except allsuj_* ; clc ;

[design,neighbours]     = h_create_design_neighbours(length(allsuj_GA),allsuj_GA{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'fdr';
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

for nt = 1:3
    for nc = 1:2
        stat{nt,nc}                            = ft_freqstatistics(cfg, allsuj_GA{:,nt+1,nc}, allsuj_GA{:,1,nc});
        [min_p(nt,nc),p_val{nt,nc}]           = h_pValSort(stat{nt,nc});
    end
end

for nt = 1:3
    for nc = 1:2
        stat{nt,nc}.mask            = stat{nt,nc}.prob < 0.05;
        stat2plot{nt,nc}.pdcspctrm  = stat{nt,nc}.mask .* stat{nt,nc}.stat;
        stat2plot{nt,nc}.dimord     = stat{nt,nc}.dimord;
        stat2plot{nt,nc}.label      = stat{nt,nc}.label;
        stat2plot{nt,nc}.freq       = stat{nt,nc}.freq;
        
        stat2plot{nt,nc}.pdcspctrm(stat2plot{nt,nc}.pdcspctrm<0) = 0;
        
    end
end

for nt = 1:3
    cfg           = [];
    cfg.parameter = 'pdcspctrm';
    cfg.xlim      = [1 15];
    cfg.zlim      = [-5 5];
    figure;
    ft_connectivityplot(cfg, stat2plot{nt,:});
end