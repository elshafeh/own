clear ; clc;

if isunix
    start_dir               = '/project/';
else
    start_dir               = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    list_cond               = {'pre','retro','correct','incorrect','fast','slow'};
    
    for ncond = 1:length(list_cond)
        
        ext_name            = ['/project/3015039.06/hesham/bil/tf/' subjectName '.cuelock.mtmconvolPOW.m1p7s.20msStep.1t100Hz.1HzStep.AvgTrials.'];
        if ncond ==1 || ncond == 2
            flist          	= dir([ext_name '*.' list_cond{ncond} '.*.*.mat']);
        elseif ncond ==3 || ncond == 4
            flist          	= dir([ext_name '*.*.' list_cond{ncond} '.*.mat']);
        elseif ncond ==3 || ncond == 4
            flist          	= dir([ext_name '*.*.*.' list_cond{ncond} '.mat']);
        end
        
        for nfile = 1:length(flist)
            fname           = [flist(nfile).folder filesep flist(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            tmp{nfile}      = freq_comb; clear freq_comb;
        end
        
        freq                = ft_freqgrandaverage([],tmp{:}); clear tmp;
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        alldata{nsuj,ncond} = freq; clear freq;
        
    end
end

keep alldata list_cond

list_test                       = [1 2; 3 4; 5 6];
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
    cfg.minnbchan               = 3; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    i                           = i +1;
    ix1                         = list_test(ntest,1);
    ix2                         = list_test(ntest,2);
    
    cfg.latency                 = [-0.2 6];
    cfg.frequency               = [50 100];
    
    list_name{i}                = [list_cond{ix1} ' versus ' list_cond{ix2}];
    stat{i}                     = ft_freqstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]        = h_pValSort(stat{i});
    
end

keep alldata list_cond stat list_name min_p p_val

for ntest = 2
    
    list_vline              = [0 0 0; 0 0 2; 0 2 4];
    
    cfg                     = [];
    cfg.layout             	= 'CTF275.lay';
    cfg.zlim                = [-3 3];
    cfg.colormap         	= brewermap(256,'*RdBu');
    cfg.plimit           	= 0.2;
    cfg.vline               = [0 1.5 3 4.5];
    cfg.sign                = [-1 1];
    
    h_plotstat_3d(cfg,stat{ntest});

end