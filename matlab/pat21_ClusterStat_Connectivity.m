clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

cnd = {'VCnD','NCnD'};

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))];
    
    for c = 1:length(cnd)
        
        for b = 1:3
            
            
            fname_in = dir(['../data/' suj '/pe/' suj '.pt' num2str(b) '.' cnd{c} '.5t15Hz.15lmd.timeCourse.NoAvg.mat']);
            fprintf('\nLoading %50s \n',fname_in.name);
            load(['../data/' suj '/pe/' fname_in.name])
            
            carr{b} = virtsens;
            
            clear virtsens
            
        end
        
        appnd = ft_appenddata([],carr{:});
        
        cfg                     = [];
        cfg.output              = 'fourier';
        cfg.method              = 'mtmfft';
        cfg.toilim              = [0 1.2];
        cfg.foilim              = [7 14];
        cfg.tapsmofrq           = 0.4;
        freq                    = ft_freqanalysis(cfg,appnd);
        
        cfg                     = [];
        cfg.method              = 'coh';
        allsuj_GA{a,c}          = ft_connectivityanalysis(cfg,freq);
        
        clear appnd
        
    end
    
end

clc;clearvars -except cnd suj_list allsuj_GA;create_design_neighbours;clc;

cfg                     = [];
cfg.parameter           = 'cohspctrm';
cfg.frequency           = [7 14] ;
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.alpha               = 0.05;
cfg.correctm            = 'bonferroni';
cfg.correcttail         = 'prob';
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;
stat                    = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});clc;n_sig = find(stat.mask~=0);



% for n = 1:length(cnct)
%     fprintf('Sig between %s and %s at %.2f\n',allsuj_GA{1,1}.label{cnct(n,1)},allsuj_GA{1,1}.label{cnct(n,2)},allsuj_GA{1,1}.freq(cnct(n,3)));
% end