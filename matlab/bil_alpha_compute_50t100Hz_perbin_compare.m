clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    subjectName                 = suj_list{ns};
    
    for nb = 1:5
        
        fname                   = ['J:\temp\bil\tf\' subjectName '.cuelock.alphabin' num2str(nb) '.50t100Hz.comb.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        t1                      = find(round(freq_comb.time,2) == round(-0.4,2));
        t2                      = find(round(freq_comb.time,2) == round(-0.2,2));
        
        bsl                     = mean(freq_comb.powspctrm(:,:,t1:t2),3);
        freq_comb.powspctrm 	= (freq_comb.powspctrm  - bsl) ./bsl;
        
        alldata{ns,nb}          = freq_comb; clear avg t1 t2 bsl fname;
        
    end
end

keep alldata

nsuj                    	= size(alldata,1);
[design,neighbours]      	= h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

cfg                     	= [];
cfg.method              	= 'ft_statistics_montecarlo';
cfg.statistic            	= 'ft_statfun_depsamplesFmultivariate';
cfg.correctm              	= 'cluster';
cfg.clusteralpha           	= 0.05;
cfg.clusterstatistic      	= 'maxsum';
cfg.clusterthreshold      	= 'nonparametric_common';
cfg.tail                 	= 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail         	= cfg.tail;
cfg.alpha               	= 0.05;
cfg.computeprob           	= 'yes';
cfg.numrandomization      	= 1000;
cfg.neighbours             	= neighbours;
cfg.latency                 = [-0.1 5];

cfg.minnbchan               = 2; % !!
cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;

nbsuj                       = size(alldata,1);

design                      = zeros(2,5*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(1,nbsuj*3+1:4*nbsuj) = 4;
design(1,nbsuj*4+1:5*nbsuj) = 5;
design(2,:)                 = repmat(1:nbsuj,1,5);

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_freqstatistics(cfg, alldata{:,1},alldata{:,2},alldata{:,3},alldata{:,4},alldata{:,5});

for ns = 1:size(alldata,1)
    for nb = 1:size(alldata,2)
        cfg             =[];
        cfg.latency     = stat.time([1 end]);
        cfg.frequency   = stat.freq([1 end]);
        cfg.channel     = stat.label;
        newdata{ns,nb}  = ft_selectdata(cfg,alldata{ns,nb}); clc;
    end
end

nrow                        = 2;
ncol                        = 2;
i                        	= 0;