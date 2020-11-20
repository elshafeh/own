clear ;

suj_list                                = dir('../data/sub*');

for ns = 1:length(suj_list)
    
    subjectName         = suj_list(ns).name;
    fname               = ['../data/' subjectName '/tf/' subjectName '.firstcuelock.mtmconvol.comb.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    period_baseline     = [-0.4 -0.2];
    period_interest     = [-0.2 6];
    freq_interest       = [1 40];
    [act,bsl]           = h_prepareBaseline(freq_comb,period_baseline,period_interest,freq_interest,'na');
    
    alldata{ns,1}       = bsl; clear bsl;
    alldata{ns,2}       = act; clear act;
    
    
end

clearvars -except alldata

nsuj                    = size(alldata,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';

cfg.neighbours          = neighbours;
cfg.clusteralpha        = 0.05; % !!
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.clustertail         = 0;

cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

cfg.minnbchan           = 4; % !!
cfg.latency             = [-0.2 5];
cfg.frequency           = [1 30];

stat                    = ft_freqstatistics(cfg, alldata{:,2},alldata{:,1});
stat                    = rmfield(stat,'cfg');

[min_p, p_val]          = h_pValSort(stat);