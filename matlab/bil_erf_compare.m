clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    list_cond                   = {'pre','retro'};
    
    for ncue = 1:2
        
        dir_data                = 'I:\bil\erf\';
        fname                   = [dir_data subjectName '.' list_cond{ncue}  '.cue.correct.erf.comb.mat'];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        cfg                     = [];
        cfg.baseline            = [-0.1 0];
        alldata{nsuj,ncue}      = ft_timelockbaseline(cfg,avg_comb);
        
        
    end
end

keep alldata list_cond

list_test                       = [1 2];
list_name                       = {};
i                               = 0;

for ntest = 1:size(list_test,1)
    
    nsuj                        = size(alldata,1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 4; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    i                           = i +1;
    ix1                         = list_test(ntest,1);
    ix2                         = list_test(ntest,2);
    
    cfg.latency                 = [-0.1 6];
    
    list_name{i}                = [[list_cond{ix1}] ' versus ' [list_cond{ix2}]];
    stat{i}                     = ft_timelockstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]        = h_pValSort(stat{i});
    
end

close all;

for ntest = 1:length(stat)
    
    ix1                         = list_test(ntest,1);
    ix2                         = list_test(ntest,2);
    
    cfg                         = [];
    cfg.layout                  = 'CTF275.lay';
    %     cfg.zlim                    = [-3 3];
    %     cfg.ylim                    = [-0.6 0.35];
    cfg.colormap                = brewermap(256,'*RdBu');
    cfg.plimit                  = 0.05;
    cfg.vline                   = [0 1.5 3 4.5 5.5];
    cfg.sign                    = [-1 1];
    cfg.maskstyle               = 'highlight'; %'nan';
    cfg.title                   = list_name{ntest};
    cfg.xticks                  = cfg.vline;
    cfg.xticklabels             = {'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'Mean RT'};
    
    h_plotstat_2d(cfg,stat{ntest},alldata(:,[ix1 ix2]));
    
end